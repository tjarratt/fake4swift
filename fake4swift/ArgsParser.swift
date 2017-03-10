import Foundation
import Commandant
import Result

class ArgsParser {
    enum Error: String, Swift.Error, CustomStringConvertible {
        case InsufficientArguments
        case ExtraArguments

        var description: String {
            switch self {
            case .InsufficientArguments: return "Not enough arguments provided."
            case .ExtraArguments: return "Too many arguments provided."
            }
        }
    }

    let args: [String]

    init(args: [String] = CommandLine.arguments) {
        self.args = args
    }

    func parse() throws -> ParsedArguments {
        switch args.count {
        case 0...1: throw Error.InsufficientArguments
        case 2: return ParsedArguments(fileName: args[1], protocolName: nil, destinationDirectory: nil)
        case 3: return ParsedArguments(fileName: args[1], protocolName: args[2], destinationDirectory: nil)
        default: throw Error.ExtraArguments
        }
    }
}

fileprivate struct FakeSwiftOptions: OptionsProtocol {
    fileprivate let fileName: String
    fileprivate let protocolName: String?
    fileprivate let destinationDirectory: String?

    fileprivate static func create(_ fileName: String) -> (String?) -> (String?) -> FakeSwiftOptions {
        return { protocolName in { destinationDirectory in
            FakeSwiftOptions(fileName: fileName, protocolName: protocolName, destinationDirectory: destinationDirectory)
        } }
    }

    fileprivate static func evaluate(_ m: CommandMode) -> Result<FakeSwiftOptions, CommandantError<ArgsParser.Error>> {
        return create
            <*> m <| Argument(usage: "File to read")
            <*> m <| Argument(usage: "Protocol to fake")
            <*> m <| Option(key: "destination", defaultValue: nil, usage: "Write generated code to directory instead of 'fakes'")
    }
}

struct ParsedArguments {
    let fileName: String
    let protocolName: String?
    let destinationDirectory: String?
}
