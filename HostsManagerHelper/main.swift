//
//  main.swift
//  HostsManagerHelper
//
//  Created on February 9, 2026.
//

import Foundation

/// Entry point for the privileged helper tool
class HelperToolMain {
    static func main() {
        let delegate = HelperToolDelegate()
        let listener = NSXPCListener(machServiceName: AppConstants.helperMachServiceName)

        AppLogger.helper.info("Privileged helper tool started")

        listener.delegate = delegate
        listener.resume()

        RunLoop.current.run()
    }
}

/// Delegate for handling XPC connections
class HelperToolDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        AppLogger.helper.info("Received new XPC connection request")

        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        newConnection.exportedObject = HelperService()

        newConnection.invalidationHandler = {
            AppLogger.helper.info("XPC connection invalidated")
        }

        newConnection.interruptionHandler = {
            AppLogger.helper.warning("XPC connection interrupted")
        }

        newConnection.resume()
        AppLogger.helper.info("XPC connection accepted and resumed")
        return true
    }
}

// Run the helper
HelperToolMain.main()
