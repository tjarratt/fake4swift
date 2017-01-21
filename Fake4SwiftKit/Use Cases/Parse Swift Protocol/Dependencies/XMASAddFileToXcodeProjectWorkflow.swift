import Foundation

@objc public protocol XMASAddFileToXcodeProjectWorkflow {
    @objc func addFileToXcode(
        _ file: String,
        alongsideFileNamed: String,
        directory: String
    ) throws
}
