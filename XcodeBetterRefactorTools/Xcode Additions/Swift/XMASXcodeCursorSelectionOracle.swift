import Foundation
import BetterRefactorToolsKit

@objc class XMASXcodeCursorSelectionOracle : NSObject, XMASSelectedProtocolOracle, XMASSelectedStructOracle {
    fileprivate(set) var xcodeRepository : XMASXcodeRepository

    init(xcodeRepo : XMASXcodeRepository) {
        xcodeRepository = xcodeRepo
    }

    // Mark - selected protocols

    @objc func isProtocolSelected(_ protocolDecl : ProtocolDeclaration) -> Bool {
        let selectedRange : NSRange = xcodeRepository.cursorSelectionRange()
        return rangesOverlap(selectedRange, otherRange: protocolDecl.rangeInFile)
    }

    // Mark - selected structs

    @objc func isStructSelected(_ structDecl: StructDeclaration) -> Bool {
        let selectedRange : NSRange = xcodeRepository.cursorSelectionRange()
        return rangesOverlap(selectedRange, otherRange: structDecl.rangeInFile)
    }

    // Mark - private

    fileprivate func rangesOverlap(_ cursorRange : NSRange, otherRange : NSRange) -> Bool {
        if cursorRange.location < otherRange.location {
            return false
        }

        if cursorRange.location > otherRange.location + otherRange.length {
            return false
        }

        return true
    }
}
