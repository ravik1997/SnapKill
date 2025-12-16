import Foundation
import Combine
import os
import SwiftUI

struct RunningProcess: Identifiable, Hashable {
    let id = UUID()
    let pid: Int32
    let name: String
    let fullPath: String?
    let port: Int?
    
    // Custom hash and equality to avoid UI flickering updates based on UUID
    func hash(into hasher: inout Hasher) {
        hasher.combine(pid)
    }
    
    static func == (lhs: RunningProcess, rhs: RunningProcess) -> Bool {
        return lhs.pid == rhs.pid
    }
}

class ProcessManager: ObservableObject {
    enum AppState: Equatable {
        case idle
        case searching
        case results([RunningProcess])
        case error(String)
    }
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? Constants.App.subsystem, category: "ProcessManager")
    @Published var state: AppState = .idle
    
    // Safe command runner helper (avoids shell injection)
    private func execute(command: String, arguments: [String]) -> String {
        let task = Process()
        let outPipe = Pipe()
        let errPipe = Pipe()
        
        task.standardOutput = outPipe
        task.standardError = errPipe
        
        // Use /usr/bin/env to locate the command in the PATH (including /usr/sbin)
        task.launchPath = Constants.Commands.env
        
        // env takes the command as the first argument
        var allArguments = [command]
        allArguments.append(contentsOf: arguments)
        task.arguments = allArguments
        
        // Ensure PATH includes /usr/sbin for lsof
        task.environment = ["PATH": "/usr/bin:/bin:/usr/sbin:/sbin"]
        
        do {
            try task.run()
        } catch {
            logger.error("Failed to run command: \(command, privacy: .public) \(arguments, privacy: .public). Error: \(error.localizedDescription)")
            return ""
        }
        
        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errData, encoding: .utf8) ?? ""
        
        if !errorOutput.isEmpty {
            // Filter out benign system warnings about protected processes
            if !errorOutput.contains("Unable to obtain a task name port") {
                logger.debug("Command stderr: \(command) -> \(errorOutput)")
            }
        }
        
        return output
    }
    // MARK: - Private Helpers
    
    private func startSearch() {
        DispatchQueue.main.async {
            withAnimation {
                self.state = .searching
            }
        }
    }
    
    private func finishSearch(results: [RunningProcess], notFoundMessage: String) {
        DispatchQueue.main.async {
            withAnimation {
                if results.isEmpty {
                    self.logger.notice("\(notFoundMessage, privacy: .public)")
                    self.state = .error(notFoundMessage)
                } else {
                    self.logger.notice("Found \(results.count) processes")
                    self.state = .results(results)
                }
            }
        }
    }
    
    private func resolveProcessDetails(for pids: [Int32]) -> [Int32: (name: String, path: String)] {
        guard !pids.isEmpty else { return [:] }
        
        let pidString = pids.map { String($0) }.joined(separator: ",")
        // ps -p 1,2,3 -o pid=,comm=
        // Output format: <pid> <command>
        let output = self.execute(command: Constants.Commands.ps, arguments: ["-p", pidString, "-o", "pid=,comm="])
        
        var results: [Int32: (name: String, path: String)] = [:]
        
        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            if parts.count == 2, let pid = Int32(parts[0]) {
                var rawPath = String(parts[1])
                rawPath = rawPath.replacingOccurrences(of: "\\x20", with: " ")
                let trimmedPath = rawPath.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Safety check for massive garbage
                if trimmedPath.count > Constants.Search.maxPathLength { continue }
                
                let url = URL(fileURLWithPath: trimmedPath)
                let name = url.lastPathComponent
                let safeName = name.count > Constants.Search.maxNameLength ? String(name.prefix(Constants.Search.maxNameLength)) + "..." : name
                
                results[pid] = (safeName, trimmedPath)
            }
        }
        
        return results
    }
    
    func fetchProcesses(onPort port: Int) {
        self.startSearch()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.logger.info("Fetching processes on port: \(port)")
            
            let output = self.execute(command: Constants.Commands.lsof, arguments: ["-i", ":\(port)"])
            var newProcesses: [RunningProcess] = []
            
            let lines = output.components(separatedBy: .newlines)
            // Skip header
            if lines.count > 1 {
                var pidMap: [Int32: (name: String, port: Int)] = [:]
                
                for line in lines.dropFirst() {
                    let parts = line.split(separator: " ", omittingEmptySubsequences: true)
                    // We expect at least COMMAND and PID.
                    if parts.count >= 2, let pid = Int32(parts[1]) {
                        var shortName = String(parts[0])
                        shortName = shortName.replacingOccurrences(of: "\\x20", with: " ")
                        
                        // Just store the first occurrence for this PID
                        if pidMap[pid] == nil {
                            pidMap[pid] = (shortName, port)
                        }
                    }
                }
                
                // Batch resolve details
                let pids = Array(pidMap.keys)
                let details = self.resolveProcessDetails(for: pids)
                
                for (pid, info) in pidMap {
                    var finalName = info.name
                    var fullPath: String? = nil
                    
                    if let detail = details[pid] {
                        finalName = detail.name
                        fullPath = detail.path
                    }
                    
                    newProcesses.append(RunningProcess(pid: pid, name: finalName, fullPath: fullPath, port: info.port))
                }
            }
            
            self.finishSearch(results: newProcesses, notFoundMessage: String(format: Constants.Search.notFoundOnPort, port))
        }
    }
    
    func searchProcesses(byName name: String) {
        self.startSearch()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.logger.info("Searching processes by name: \(name, privacy: .public)")
            
            // Removed "-f" to search only process names, avoiding false positives from file paths in arguments.
            let output = self.execute(command: Constants.Commands.pgrep, arguments: ["-l", "-i", name])
            var newProcesses: [RunningProcess] = []
            
            let lines = output.components(separatedBy: .newlines)
            var pidsToResolve: [Int32] = []
            var initialNames: [Int32: String] = [:] // PID to raw pgrep name
            
            for line in lines {
                let parts = line.split(separator: " ", omittingEmptySubsequences: true)
                if parts.count >= 2, let pid = Int32(parts[0]) {
                    pidsToResolve.append(pid)
                    // store the messy pgrep name as fallback
                    var fullString = parts.dropFirst().joined(separator: " ")
                    fullString = fullString.replacingOccurrences(of: "\\x20", with: " ")
                    initialNames[pid] = fullString
                }
            }
            
            // Batch resolve
            let details = self.resolveProcessDetails(for: pidsToResolve)
            
            for pid in pidsToResolve {
                 var processName = initialNames[pid] ?? "Unknown"
                 var fullPath: String? = initialNames[pid]
                 
                 if let detail = details[pid] {
                     processName = detail.name
                     fullPath = detail.path
                 } else {
                      // Fallback cleanup
                      if processName.count > Constants.Search.maxNameLength {
                          processName = String(processName.prefix(Constants.Search.maxNameLength)) + "..."
                      }
                 }
                 
                 newProcesses.append(RunningProcess(pid: pid, name: processName, fullPath: fullPath, port: nil))
            }
            
            self.finishSearch(results: newProcesses, notFoundMessage: String(format: Constants.Search.notFoundByName, name))
        }
    }
    
    func killProcess(_ process: RunningProcess) {
        logger.info("Killing process: \(process.name) (PID: \(process.pid))")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            _ = self.execute(command: Constants.Commands.kill, arguments: ["-9", "\(process.pid)"])
            
            // Remove from list
            DispatchQueue.main.async {
                withAnimation {
                    if case .results(var currentProcesses) = self.state {
                        currentProcesses.removeAll { $0.pid == process.pid }
                        self.state = currentProcesses.isEmpty ? .idle : .results(currentProcesses)
                    }
                }
            }
        }
    }
    
    func killAll() {
        guard case .results(let currentProcesses) = self.state else { return }
        logger.warning("Killing all \(currentProcesses.count) listed processes")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            for process in currentProcesses {
                _ = self.execute(command: Constants.Commands.kill, arguments: ["-9", "\(process.pid)"])
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.state = .idle
                }
            }
        }
    }
}
