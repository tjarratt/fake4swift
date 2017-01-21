import Foundation
import Fake4SwiftKit

@objc class TerminalAlerter : NSObject, XMASAlerter {
    @objc func flashMessage(_ message: String!, with imageName: XMASAlertImage, shouldLogMessage: Bool) {
        print(message)
    }

    @objc public func flashComfortingMessage(forError error: Error!) {
        print("Error: \(error.localizedDescription)")
    }

    @objc func flashComfortingMessage(for exception: NSException!) {
        print("2spooky5me")
    }
}
