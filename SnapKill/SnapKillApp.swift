//
//  PSKillerApp.swift
//  PSKiller
//
//  Created by Ravi Kumar on 16/12/25.
//

import SwiftUI

@main
struct SnapKillApp: App {
    var body: some Scene {
        MenuBarExtra(Constants.App.name, systemImage: Constants.App.menuBarIcon) {
            MenuBarView()
        }
        .menuBarExtraStyle(.window) // Allows for complex SwiftUI views in the popover
    }
}
