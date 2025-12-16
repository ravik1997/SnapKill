import Foundation
import Combine
import ServiceManagement

class LaunchAtLoginManager: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            updateLaunchAtLogin()
        }
    }
    
    init() {
        // Check current status from system
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }
    
    private func updateLaunchAtLogin() {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error.localizedDescription)")
            // Sync back to actual state if operation failed
            DispatchQueue.main.async { [weak self] in
                self?.isEnabled = SMAppService.mainApp.status == .enabled
            }
        }
    }
}
