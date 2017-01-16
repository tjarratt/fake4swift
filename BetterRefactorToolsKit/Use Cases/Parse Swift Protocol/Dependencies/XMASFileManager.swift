import Foundation

@objc public protocol XMASFileManager {
    func fileExistsAtPath(
        _ path: String,
        isDirectory: UnsafeMutablePointer<ObjCBool>) -> Bool

    func createDirectoryAtPath(
        _ path: String,
        withIntermediateDirectories: Bool,
        attributes: [String : AnyObject]?) throws

    func createFileAtPath(
        _ path: String,
        contents: Data?,
        attributes: [String : AnyObject]?) -> Bool
}

extension FileManager : XMASFileManager {}
