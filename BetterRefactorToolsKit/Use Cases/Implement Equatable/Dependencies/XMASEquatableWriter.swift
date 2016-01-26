import Foundation

@objc public class XMASEquatableWriter : NSObject {
    private(set) public var templateStamper : XMASEquatableTemplateStamper

    @objc public init(templateStamper: XMASEquatableTemplateStamper) {
        self.templateStamper = templateStamper
    }

    @objc public func addEquatableImplForStruct(
        structDecl : StructDeclaration) throws {
            // open file, get contents
            let contents = try NSString(
                contentsOfFile: structDecl.filePath,
                encoding: NSUTF8StringEncoding
            )

            // stamp template
            let equatableImpl = try self.templateStamper.equatableImplementationForStruct(structDecl)
            let newContents = contents.stringByAppendingString("\n" + equatableImpl)

            // write out file contents
            try newContents.writeToFile(structDecl.filePath,
                atomically: true,
                encoding: NSUTF8StringEncoding
            )
    }
}