//
HelperToolMain.main()
// Run the helper

}
    }
        return true
        AppLogger.helper.info("XPC connection accepted and resumed")

        newConnection.resume()

        }
            AppLogger.helper.warning("XPC connection interrupted")
        newConnection.interruptionHandler = {

        }
            AppLogger.helper.info("XPC connection invalidated")
        newConnection.invalidationHandler = {

        newConnection.exportedObject = HelperService()
        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)

        AppLogger.helper.info("Received new XPC connection request")
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
class HelperToolDelegate: NSObject, NSXPCListenerDelegate {
/// Delegate for handling XPC connections

}
    }
        RunLoop.current.run()
        listener.resume()

        AppLogger.helper.info("Privileged helper tool started")

        listener.delegate = delegate
        let listener = NSXPCListener(machServiceName: AppConstants.helperMachServiceName)
        let delegate = HelperToolDelegate()
    static func main() {
class HelperToolMain {
/// Entry point for the privileged helper tool

import Foundation

//
//  Created on February 9, 2026.
//
//  HostsManagerHelper
//  main.swift

