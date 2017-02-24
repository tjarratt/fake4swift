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
                    expect(try! subject.setMyAttributeArgs(forCall: 0)).to(equal(12))

                    subject.myAttribute = 666
                    expect(subject.myAttribute).to(equal(666))
                    expect(try! subject.setMyAttributeArgs(forCall: 1)).to(equal(666))
                    expect(subject.setMyAttributeCallCount()).to(equal(2))
                }

                it("blows up if you ask for an invalid invocation") {
                    expect { try subject.setMyAttributeArgs(forCall: -1) }.to(throwError())
                    expect { try subject.setMyAttributeArgs(forCall: 222) }.to(throwError())
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
                    expect(try! subject.setMyNameArgs(forCall: 0)).to(equal("Bobby BigTime!"))
                    expect(subject.setMyNameCallCount()).to(equal(1))

                    subject.myName = "Doin it Big"
                    expect(subject.myName).to(equal("Doin it Big"))
                    expect(try! subject.setMyNameArgs(forCall: 1)).to(equal("Doin it Big"))
                    expect(subject.setMyNameCallCount()).to(equal(2))
                }

                it("blows up if you ask for an invalid invocation") {
                    expect { try subject.setMyNameArgs(forCall: -1) }.to(throwError())
                    expect { try subject.setMyNameArgs(forCall: 222) }.to(throwError())
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
                    subject.doesStuffReturns(stubbedValues: (["test-yo"], 5))

                    let tuple = subject.doesStuff(stuff: "this", otherStuff: ["that"])
                    expect(tuple.0).to(equal(["test-yo"]))
                    expect(tuple.1).to(equal(5))
                }

                it("allows you to write assertions for the arguments passed into each invocation") {
                    subject.doesStuffReturns(stubbedValues: ([], 0))
                    let _ = subject.doesStuff(stuff: "kool", otherStuff: ["keith"])

                    var args = subject.doesStuffArgs(forCall: 0)
                    expect(args.0).to(equal("kool"))
                    expect(args.1).to(equal(["keith"]))

                    let _ = subject.doesStuff(stuff: "dr", otherStuff: ["octogon"])

                    args = subject.doesStuffArgs(forCall: 1)
                    expect(args.0).to(equal("dr"))
                    expect(args.1).to(equal(["octogon"]))
                }
            }

            describe("static methods") {
                beforeEach() {
                    FakeMySomewhatSpecialProtocol.reset()
                }

                it("allows you to call them and observe that they were invoked") {
                    expect(FakeMySomewhatSpecialProtocol.staticMethodCallCount).to(equal(0))

                    FakeMySomewhatSpecialProtocol.staticMethodStub = {(_ : String, _: Bool) -> [String] in
                        return ["this", "that", "test"]
                    }
                    let _ = FakeMySomewhatSpecialProtocol.staticMethod(isStatic: "real-talk", soStatic: false)

                    expect(FakeMySomewhatSpecialProtocol.staticMethodCallCount).to(equal(1))
                }

                it("allows you to stub the return value for methods that return values") {
                    FakeMySomewhatSpecialProtocol.staticMethodReturns(stubbedValues: ["radiation", "sickness"])

                    let stubbedValues = FakeMySomewhatSpecialProtocol.staticMethod(isStatic: "is bad", soStatic: true)
                    expect(stubbedValues).to(equal(["radiation", "sickness"]))
                }

                it("allows you to write assertions for the arguments passed into each invocation") {
                    FakeMySomewhatSpecialProtocol.staticMethodReturns(stubbedValues: ["dream", "a", "little", "dream", "of", "me"])
                    let _ = FakeMySomewhatSpecialProtocol.staticMethod(isStatic: "sup", soStatic: true)

                    var args = FakeMySomewhatSpecialProtocol.staticMethodArgs(forCall: 0)
                    expect(args.0).to(equal("sup"))
                    expect(args.1).to(equal(true))

                    let _ = FakeMySomewhatSpecialProtocol.staticMethod(isStatic: "republic-of-dave", soStatic: false)
                    args = FakeMySomewhatSpecialProtocol.staticMethodArgs(forCall: 1)
                    expect(args.0).to(equal("republic-of-dave"))
                    expect(args.1).to(equal(false))
                }
            }

            describe("methods that receive and return optionals") {
                var drummer : String?

                beforeEach() {
                    subject.soulOfAFunkyReturns(stubbedValues: "this-or-that")
                    try! subject.soulOfAFunky(drummer: drummer)
                }

                it("allows you to inspect the args that were passed in") {
                    expect(subject.soulOfAFunkyArgs(forCall: 0)).to(beNil())
                }

                it("allows you to call them and observe that they were invoked") {
                    expect(subject.soulOfAFunkyCallCount).to(equal(1))
                }

                context("given a non-nil value") {
                    beforeEach() {
                        drummer = "clyde stubblefield"
                        try! subject.soulOfAFunky(drummer: drummer)
                    }

                    it("records the argument") {
                        expect(subject.soulOfAFunkyCallCount).to(equal(2))
                        expect(subject.soulOfAFunkyArgs(forCall: 1)).to(equal("clyde stubblefield"))
                    }
                }

                context("when it would throw") {
                    beforeEach() {
                        subject.soulOfAFunkyStub = {(_ : String?) throws -> String? in
                            throw NSError.init(domain: "", code: 0, userInfo: nil)
                        }
                    }

                    it("can be expected to throw an error") {
                        expect {
                            try subject.soulOfAFunky(drummer: "sup")
                        }.to(throwError())
                    }
                }
            }

            describe("equality") {
                it("should be equal to itself") {
                    expect(subject).to(equal(subject));
                }
            }
        }
    }
}
