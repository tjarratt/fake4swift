import Quick
import Nimble

class FakeMyMutatingProtocolSpec: QuickSpec {
    override func spec() {
        describe("a generated fake for a protocol with mutable methods") {
            var subject : FakeMyMutatingProtocol!

            beforeEach() {
                subject = FakeMyMutatingProtocol.init()
                subject.mutableMethodStub = {(_: String, _: String) -> String in
                    return "whoops"
                }
            }

            it("conforms to the MyMutatingProtocol protocol") {
                var test : MyMutatingProtocol
                test = subject
                expect(test).toNot(beNil())
            }

            it("allows you to observe that a method was called") {
                expect(subject.mutableMethodCallCount).to(equal(0))
                let _ = subject.mutableMethod(arg: "this", arg2: "that")

                expect(subject.mutableMethodCallCount).to(equal(1))
            }

            it("allows you to observe the args that were passed in") {
                let _ = subject.mutableMethod(arg: "this", arg2: "that")

                let tuple = subject.mutableMethodArgs(forCall: 0)
                expect(tuple.0).to(equal("this"))
                expect(tuple.1).to(equal("that"))
            }

            it("allows you to stub the return value") {
                subject.mutableMethodReturns(stubbedValues: "UP FROM THE THIRTY SIX CHAMBERS. IT'S THE GHOST")

                expect(subject.mutableMethod(arg: "wu", arg2: "tang")).to(equal(
                    "UP FROM THE THIRTY SIX CHAMBERS. IT'S THE GHOST"
                ))
            }

            describe("equality") {
                it("should be equal to itself") {
                    expect(subject).to(equal(subject));
                }
            }
        }
    }
}
