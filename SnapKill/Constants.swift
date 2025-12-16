import Foundation
import SwiftUI

enum Constants {
    enum App {
        static let name = "SnapKill"
        static let subsystem = "com.snapkill"
        static let menuBarIcon = "bolt.circle"
    }
    
    enum Search {
        static let placeholder = "Enter port (8080) or name"
        static let loadingText = "Searching..."
        static let noProcessesFound = "No processes found"
        static let notFoundOnPort = "No processes found on port %d"
        static let foundOnPort = "Found %d processes on port %d"
        static let notFoundByName = "No processes found matching '%@'"

        static let foundByName = "Found %d processes matching '%@'"
        static let resultsSummary = "%d processes found"
        
        static let maxPathLength = 1024
        static let maxNameLength = 64
    }
    
    enum UI {
        static let killAll = "Kill All"
        static let killIcon = "xmark.circle.fill"
        static let searchIcon = "magnifyingglass"
        static let clearIcon = "xmark.circle.fill"
        static let errorIcon = "exclamationmark.triangle"
        

        static let maxHeight: CGFloat = 450


        // Extra height for header/footer components when content is present
        static let extraPadding: CGFloat = 80
        static let width: CGFloat = 300
    }
    
    enum Animation {
        static let springResponse: Double = 0.35
        static let springDamping: Double = 0.75
        static let hoverDuration: Double = 0.2
    }
    
    enum Commands {
        static let lsof = "lsof"
        static let ps = "ps"
        static let pgrep = "pgrep"
        static let kill = "kill"
        static let shell = "/bin/zsh"
        static let env = "/usr/bin/env"
    }
}
