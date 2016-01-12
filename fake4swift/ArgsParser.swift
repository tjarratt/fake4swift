import Foundation

class ArgsParser {
    enum Error: String, ErrorType, CustomStringConvertible {
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

    init(args: [String] = Process.arguments) {
        self.args = args
    }

    func parse() throws -> (fileName: String, protocolName: String?) {
        switch args.count {
        case 0...1: throw Error.InsufficientArguments
        case 2: return (args[1], nil)
        case 3: return (args[1], args[2])
        default: throw Error.ExtraArguments
        }
    }
}
