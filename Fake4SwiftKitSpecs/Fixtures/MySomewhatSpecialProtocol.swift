protocol MySomewhatSpecialProtocol {
    var myAttribute : Int { get }
    var myName : String { get set }

    var optionalProperty : Int? { get set }

    func doesNothing()
    func doesStuff(thisStuff stuff: String, thatStuff otherStuff: [String]) -> ([String], Int)

    static func staticMethod(isStatic: String, soStatic: Bool) -> Array<String>

    func soulOfAFunky(drummer: String?) throws -> String?
}
