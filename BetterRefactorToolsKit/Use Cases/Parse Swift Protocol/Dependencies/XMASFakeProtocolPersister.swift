import Foundation

@objc public class XMASFakeProtocolPersister : NSObject {
    private(set) public var fileManager : XMASFileManager
    private(set) public var protocolFaker : XMASSwiftProtocolFaking

    @objc public init(protocolFaker: XMASSwiftProtocolFaking, fileManager: XMASFileManager) {
        self.fileManager = fileManager
        self.protocolFaker = protocolFaker
    }

    let generatedFakesDir = "fakes"

    @objc public func persistFakeForProtocol(
        protocolDecl : ProtocolDeclaration,
        nearSourceFile: String) throws -> FakeProtocolPersistResults
    {
        let dirContainingSource = (nearSourceFile as NSString).stringByDeletingLastPathComponent
        let fakesDir = (dirContainingSource as NSString).stringByAppendingPathComponent(generatedFakesDir)

        let fakeFileName = ["Fake", protocolDecl.name, ".swift"].joinWithSeparator("")
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

        return FakeProtocolPersistResults.init(
            path: pathToFake,
            containingDir: generatedFakesDir
        )
    }
}

@objc public class FakeProtocolPersistResults : NSObject {
    private(set) public var pathToFake : String
    private(set) public var directoryName : String

    public init(path: String, containingDir: String) {
        pathToFake = path
        directoryName = containingDir

        super.init()
    }
}