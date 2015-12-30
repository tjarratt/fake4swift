import Foundation
import BetterRefactorToolsKit

@objc class XMASXcodeCursorSelectionOracle : NSObject, XMASSelectedProtocolOracle {
    var xcodeRepository : XMASXcodeRepository

    init(xcodeRepo : XMASXcodeRepository) {
        xcodeRepository = xcodeRepo
    }

    @objc func isProtocolSelected(protocolDecl : ProtocolDeclaration) -> Bool {
        let selectedRange : NSRange = xcodeRepository.cursorSelectionRange()
        return rangesOverlap(selectedRange, protocolRange: protocolDecl.rangeInFile)
    }

    private func rangesOverlap(cursorRange : NSRange, protocolRange : NSRange) -> Bool {
        if cursorRange.location < protocolRange.location {
            return false
        }

        if cursorRange.location > protocolRange.location + protocolRange.length {
            return false
        }

        return true
    }
}
