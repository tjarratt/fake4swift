import Foundation

@objc open class XMASFakeProtocolPersister : NSObject {
    fileprivate(set) open var fileManager : XMASFileManager
    fileprivate(set) open var protocolFaker : XMASSwiftProtocolFaking

    @objc public init(protocolFaker: XMASSwiftProtocolFaking, fileManager: XMASFileManager) {
        self.fileManager = fileManager
        self.protocolFaker = protocolFaker
    }

    let generatedFakesDir = "fakes"

    @objc open func persistFakeForProtocol(
        _ protocolDecl : ProtocolDeclaration,
        nearSourceFile: String) throws -> FakeProtocolPersistResults
    {
        let dirContainingSource = (nearSourceFile as NSString).deletingLastPathComponent
        let fakesDir = (dirContainingSource as NSString).appendingPathComponent(generatedFakesDir)

        let fakeFileName = ["Fake", protocolDecl.name, ".swift"].joined(separator: "")
        let pathToFake = (fakesDir as NSString).appendingPathComponent(fakeFileName)

        if !fileManager.fileExistsAtPath(fakesDir as String, isDirectory: nil) {
            try self.fileManager.createDirectoryAtPath(
                fakesDir,
                withIntermediateDirectories: true,
                attributes: nil)
        }

        do {
            let fileContents = try self.protocolFaker.fakeForProtocol(protocolDecl)

            let fileData : Data = fileContents.data(using: String.Encoding.utf8)!
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

@objc open class FakeProtocolPersistResults : NSObject {
    fileprivate(set) open var pathToFake : String
    fileprivate(set) open var directoryName : String

    public init(path: String, containingDir: String) {
        pathToFake = path
        directoryName = containingDir

        super.init()
    }
}
