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

extension NSFileManager : XMASFileManager {

}

@objc public class XMASFakeProtocolPersister : NSObject {
    private(set) public var fileManager : XMASFileManager
    private(set) public var protocolFaker : XMASSwiftProtocolFaking

    @objc public init(protocolFaker: XMASSwiftProtocolFaking, fileManager: XMASFileManager) {
        self.fileManager = fileManager
        self.protocolFaker = protocolFaker
    }

    @objc public func persistFakeForProtocol(
        protocolDecl : ProtocolDeclaration,
        nearSourceFile: String) throws
    {
        let dirContainingSource = (nearSourceFile as NSString).stringByDeletingLastPathComponent
        let fakesDir = (dirContainingSource as NSString).stringByAppendingPathComponent("fakes")

        let fakeFileName : String = "Fake".stringByAppendingString(protocolDecl.name).stringByAppendingString(".swift")
        let pathToFake = (fakesDir as NSString).stringByAppendingPathComponent(fakeFileName)

        if !fileManager.fileExistsAtPath(fakesDir as String, isDirectory: nil) {
            try self.fileManager.createDirectoryAtPath(
                fakesDir,
                withIntermediateDirectories: true,
                attributes: nil)
        }

        do {
            let fileContents = try self.protocolFaker.fakeForProtocol(protocolDecl)

            let fileData : NSData = fileContents.dataUsingEncoding(NSUTF8StringEncoding)!
            fileManager.createFileAtPath(pathToFake, contents: fileData, attributes: nil)

        } catch let error as NSError {
            throw error
        }
    }
}