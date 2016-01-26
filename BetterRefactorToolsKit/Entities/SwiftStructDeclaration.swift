import Foundation

@objc public class StructDeclaration : NSObject {
    public var fieldNames : Array<String>
    public var name : String
    public var filePath : String

    public init(name : String, filePath: String, fields: Array<String>) {
        self.name = name
        self.filePath = filePath
        self.fieldNames = fields
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
           b.fieldNames == b.fieldNames
}