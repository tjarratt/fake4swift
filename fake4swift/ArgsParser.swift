import Foundation
import BetterRefactorToolsKit

@objc class SelectedProtocolFromArgs : NSObject, XMASSelectedProtocolOracle {
    @objc func isProtocolSelected(protocolDecl : ProtocolDeclaration) -> Bool {
        let args = [String](Process.arguments)
        let protocolToFake = String.fromCString(args[2])

        return protocolToFake == protocolDecl.name
    }
}

@objc class SelectedClassFromArgs : NSObject, XMASSelectedSourceFileOracle {
    @objc func selectedFilePath() -> String {
        let args = [String](Process.arguments)
        return String.fromCString(args[1])! // FIXME :: raises
    }
}
