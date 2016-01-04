import Foundation
import BetterRefactorToolsKit

@objc class TerminalAlerter : NSObject, XMASAlerter {
    @objc func flashMessage(message: String!) {
        print(message)
    }

    @objc func flashMessage(message: String!, withLogging shouldLogMessage: Bool) {
        print(message)
    }

    @objc func flashComfortingMessageForError(error: NSError!) {
        print("ruh roh!")
    }

    @objc func flashComfortingMessageForException(exception: NSException!) {
        print("2spooky5me")
    }
}
