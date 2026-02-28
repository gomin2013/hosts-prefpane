//
//  HostsManagerApp.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import SwiftUI

/// Main application entry point
@main
struct HostsManagerApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: AppConstants.minimumWindowWidth,
                    minHeight: AppConstants.minimumWindowHeight
                )
                .onAppear {
                    setupApp()
                }
        }
        .defaultSize(
            width: AppConstants.defaultWindowWidth,
            height: AppConstants.defaultWindowHeight
        )
    }

    private func setupApp() {
        AppLogger.general.info("Hosts Manager started (v\(AppConstants.appVersion))")
    }
}

/// Main content view - placeholder for standalone app
struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "network")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("Hosts Manager")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Version \(AppConstants.appVersion)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()
                .padding()

            VStack(alignment: .leading, spacing: 12) {
                Label("macOS Settings Extension", systemImage: "gearshape.2")
                Label("Manage /etc/hosts file", systemImage: "doc.text")
                Label("Secure privileged access", systemImage: "lock.shield")
            }
            .font(.body)

            Spacer()

            Text("This app extends macOS Settings.\nOpen System Settings to configure host entries.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()

            Button("Open System Settings") {
                openSystemSettings()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
