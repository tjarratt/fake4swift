import Foundation

@objc public protocol XMASFileManager {
    func fileExistsAtPath(
        path: String,
        isDirectory: UnsafeMutablePointer<ObjCBool>) -> Bool

    func createDirectoryAtPath(
        path: String,
        withIntermediateDirectories: Bool,
        attributes: [String : AnyObject]?) throws

    func createFileAtPath(
        path: String,
        contents: NSData?,
        attributes: [String : AnyObject]?) -> Bool
}

extension NSFileManager : XMASFileManager {}
