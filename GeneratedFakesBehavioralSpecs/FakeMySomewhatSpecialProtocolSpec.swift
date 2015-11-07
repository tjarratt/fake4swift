import Quick
import Nimble

class FakeMySomewhatSpecialProtocolSpec: QuickSpec {
    override func spec() {
        describe("a generated fake for a contrived protocol") {
            var subject : FakeMySomewhatSpecialProtocol!

            beforeEach() {
                subject = FakeMySomewhatSpecialProtocol.init()
            }

            it("conforms to the MySomewhatSpecialProtocol protocol") {
                var test : MySomewhatSpecialProtocol
                test = subject
                expect(test).toNot(beNil())
            }

            describe("integer attributes") {
                beforeEach() {
                    subject.myAttribute = 12
                }

                it("can be set to a given value and then read back") {
                    expect(subject.myAttribute).to(equal(12))
                }

                it("keeps track of how many times the method was called") {
                    expect(subject.setMyAttributeCallCount()).to(equal(1))
                }

                it("records each invocation's arguments") {
                    expect(try! subject.setMyAttributeArgsForCall(0)).to(equal(12))

                    subject.myAttribute = 666
                    expect(subject.myAttribute).to(equal(666))
                    expect(try! subject.setMyAttributeArgsForCall(1)).to(equal(666))
                    expect(subject.setMyAttributeCallCount()).to(equal(2))
                }

                it("blows up if you ask for an invalid invocation") {
                    expect { try subject.setMyAttributeArgsForCall(-1) }.to(throwError())
                    expect { try subject.setMyAttributeArgsForCall(222) }.to(throwError())
                }
            }

            describe("string attributes") {
                beforeEach() {
                    subject.myName = "Bobby BigTime!"
                }

                it("can be set to a given value and read back") {
                    expect(subject.myName).to(equal("Bobby BigTime!"))
                }

                it("records each invocation") {
                    expect(try! subject.setMyNameArgsForCall(0)).to(equal("Bobby BigTime!"))
                    expect(subject.setMyNameCallCount()).to(equal(1))

                    subject.myName = "Doin it Big"
                    expect(subject.myName).to(equal("Doin it Big"))
                    expect(try! subject.setMyNameArgsForCall(1)).to(equal("Doin it Big"))
                    expect(subject.setMyNameCallCount()).to(equal(2))
                }

                it("blows up if you ask for an invalid invocation") {
                    expect { try subject.setMyNameArgsForCall(-1) }.to(throwError())
                    expect { try subject.setMyNameArgsForCall(222) }.to(throwError())
                }
            }

            describe("instance methods") {
                beforeEach() {
                    subject.doesNothing()
                }

                it("allows you to call them and observe that they were invoked") {
                    expect(subject.doesNothingCallCount).to(equal(1))

                    subject.doesNothing()
                    expect(subject.doesNothingCallCount).to(equal(2))
                }

                it("allows you to stub the return value for methods that return values") {
                    subject.doesStuffReturns((["test-yo"], 5))

                    let tuple = subject.doesStuff("this", otherStuff: ["that"])
                    expect(tuple.0).to(equal(["test-yo"]))
                    expect(tuple.1).to(equal(5))
                }
            }
        }
    }
}
