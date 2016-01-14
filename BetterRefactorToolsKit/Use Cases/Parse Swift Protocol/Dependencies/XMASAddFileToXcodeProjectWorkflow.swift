import Foundation

@objc public protocol XMASAddFileToXcodeProjectWorkflow {
    @objc func addFileToXcode(
        file: String,
        alongsideFileNamed: String,
        directory: String
    ) throws
}
