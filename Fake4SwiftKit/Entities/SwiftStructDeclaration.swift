import Foundation

@objc open class StructDeclaration : NSObject {
    open var fieldNames : Array<String>
    open var name : String
    open var filePath : String
    open var rangeInFile : NSRange

    public init(name : String, range: NSRange, filePath: String, fields: Array<String>) {
        self.name = name
        self.filePath = filePath
        self.fieldNames = fields
        self.rangeInFile = range
    }

    override open func isEqual(_ object: Any?) -> Bool {
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
