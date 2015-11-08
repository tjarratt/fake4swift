protocol MySomewhatSpecialProtocol {
    var myAttribute : Int { get }
    var myName : String { get set }

    func doesNothing()
    func doesStuff(stuff: String, otherStuff: [String]) -> ([String], Int)

    static func staticMethod(isStatic: String, soStatic: Bool) -> Array<String>
}