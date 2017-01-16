import Foundation

@objc open class XMASEquatableWriter : NSObject {
    fileprivate(set) open var templateStamper : XMASEquatableTemplateStamper

    @objc public init(templateStamper: XMASEquatableTemplateStamper) {
        self.templateStamper = templateStamper
    }

    @objc dynamic open func addEquatableImplForStruct(
        _ structDecl : StructDeclaration) throws {
            // open file, get contents
            let contents = try NSString(
                contentsOfFile: structDecl.filePath,
                encoding: String.Encoding.utf8.rawValue
            )

            // stamp template
            let equatableImpl = try self.templateStamper.equatableImplementationForStruct(structDecl)
            let newContents = contents.appending("\n" + equatableImpl)

            // write out file contents
            try newContents.write(toFile: structDecl.filePath,
                atomically: true,
                encoding: String.Encoding.utf8
            )
    }
}
