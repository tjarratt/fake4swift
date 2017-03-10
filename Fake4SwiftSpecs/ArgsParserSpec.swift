import Quick
import Nimble
@testable import fake4swift

class ArgsParserSpec: QuickSpec {
    
    override func spec() {
        describe("ArgsParser") {
            it("returns an error when provided less than one argument") {
                let args = ["this-that-executable-name"]
                let subject = ArgsParser(args: args)

                expect { try subject.parse() }.to(throwError(ArgsParser.Error.InsufficientArguments))
            }

            it("returns the filename when that is all that is provided") {
                let args = ["this-that-executable-name", "file.swift"]
                let subject = ArgsParser(args: args)

                let result = try? subject.parse()
                expect(result).toNot(beNil())
                expect(result?.fileName).to(equal("file.swift"))
                expect(result?.protocolName).to(beNil())
            }

            it("returns the filename AND protocol when both are provided") {
                let args = ["this-that-executable-name", "file.swift", "MySpecialProtocol"]
                let subject = ArgsParser(args: args)

                let result = try? subject.parse()
                expect(result).toNot(beNil())
                expect(result?.fileName).to(equal("file.swift"))
                expect(result?.protocolName).to(equal("MySpecialProtocol"))
            }

            it("returns an error if you goof it up and provide too many arguments") {
                let args = ["this-that-executable-name", "file.swift", "MySpecialProtocol", "MySpecialOops"]
                let subject = ArgsParser(args: args)

                expect { try subject.parse() }.to(throwError(ArgsParser.Error.ExtraArguments))
            }

            describe("optional flags") {
                it("allows the user to provide an optional destination directory") {
                    let args = [
                        "this-that-executable-name",
                        "file.swift",
                        "MySpecialProtocol",
                        "--destination", "my-special-fakes"
                    ]
                    let subject = ArgsParser(args: args)

                    let result = try? subject.parse()
                    expect(result).toNot(beNil())
                    expect(result?.fileName).to(equal("file.swift"))
                    expect(result?.protocolName).to(equal("MySpecialProtocol"))
                    expect(result?.destinationDirectory).to(equal("my-special-fakes"))
                }
            }
        }
    }
}
