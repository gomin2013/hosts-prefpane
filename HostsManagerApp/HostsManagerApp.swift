//
}
    ContentView()
#Preview {
// MARK: - Preview

}
    }
        }
            NSWorkspace.shared.open(url)
        if let url = URL(string: "x-apple.systempreferences:") {
    private func openSystemSettings() {

    }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
        }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            }
                openSystemSettings()
            Button("Open System Settings") {

                .padding()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text("This app extends macOS Settings.\nOpen System Settings to configure host entries.")

            Spacer()

            .font(.body)
            }
                Label("Secure privileged access", systemImage: "lock.shield")
                Label("Manage /etc/hosts file", systemImage: "doc.text")
                Label("macOS Settings Extension", systemImage: "gearshape.2")
            VStack(alignment: .leading, spacing: 12) {

                .padding()
            Divider()

                .foregroundColor(.secondary)
                .font(.subheadline)
            Text("Version \(AppConstants.appVersion)")

                .fontWeight(.bold)
                .font(.largeTitle)
            Text("Hosts Manager")

                .foregroundColor(.accentColor)
                .font(.system(size: 80))
            Image(systemName: "network")
        VStack(spacing: 20) {
    var body: some View {
struct ContentView: View {
/// Main content view - placeholder for standalone app

}
    }
        AppLogger.general.info("Helper Status - Connected: \(isConnected), Version: \(version)")

        let version = await xpcService.getVersion()
        let isConnected = await xpcService.checkConnection()
    private func checkHelperStatus() async {

    }
        }
            }
                AppLogger.general.warning("Helper tool is not connected")
            } else {
                AppLogger.general.info("Helper tool is connected and responsive")
            if isConnected {
            let isConnected = await xpcService.checkConnection()
        Task {

        AppLogger.general.info("Hosts Manager started (v\(AppConstants.appVersion))")
    private func setupApp() {

    }
        }
            }
                }
                    }
                        await checkHelperStatus()
                    Task {
                Button("Check Helper Status") {
            CommandGroup(after: .appInfo) {
        .commands {
        )
            height: AppConstants.defaultWindowHeight
            width: AppConstants.defaultWindowWidth,
        .defaultSize(
        }
                }
                    setupApp()
                .onAppear {
                )
                    minHeight: AppConstants.minimumWindowHeight
                    minWidth: AppConstants.minimumWindowWidth,
                .frame(
            ContentView()
        WindowGroup {
    var body: some Scene {

    @StateObject private var xpcService = XPCService.shared
struct HostsManagerApp: App {
@main
/// Main application entry point

import SwiftUI

//
//  Created on February 9, 2026.
//
//  Hosts Manager
//  HostsManagerApp.swift

