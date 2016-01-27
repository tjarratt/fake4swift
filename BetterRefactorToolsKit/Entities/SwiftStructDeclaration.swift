import Foundation

@objc public class StructDeclaration : NSObject {
    public var fieldNames : Array<String>
    public var name : String
    public var filePath : String
    public var rangeInFile : NSRange

    public init(name : String, range: NSRange, filePath: String, fields: Array<String>) {
        self.name = name
        self.filePath = filePath
        self.fieldNames = fields
        self.rangeInFile = range
    }

    override public func isEqual(object: AnyObject?) -> Bool {
        guard let other = object as? StructDeclaration else {
            return false
        }

        return self == other
    }
}

func ==(a: StructDeclaration, b: StructDeclaration) -> Bool {
    return a.name == b.name &&
           a.filePath == b.filePath &&
           a.fieldNames == b.fieldNames &&
           NSEqualRanges(a.rangeInFile, b.rangeInFile)
}