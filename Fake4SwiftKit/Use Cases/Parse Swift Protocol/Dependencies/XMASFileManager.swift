import Foundation

@objc public protocol XMASFileManager {
    func fileExists(
        atPath: String,
        isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool

    func createDirectory(
        atPath: String,
        withIntermediateDirectories: Bool,
        attributes: [String : Any]?) throws

    func createFile(
        atPath: String,
        contents: Data?,
        attributes: [String : Any]?) -> Bool
}

extension FileManager : XMASFileManager {}
