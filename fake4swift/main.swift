import Foundation
import Fake4SwiftKit

let arguments: ParsedArguments

guard NSClassFromString("XCTestCase") == nil else {
    NSApplication().run()
    exit(0)
}

do {
    arguments = try ArgsParser(args: CommandLine.arguments).parse()
} catch let e {
    print(
        e,
        "",
        "Usage:",
        "fake4swift source_file.swift [protocol_name] [destination_directory]",
        "",
        separator: "\n"
    )
    exit(1)
}

// FIXME  you gotta use the arguments destination directory, or else you'll be sad pandas

let selectedTextWorkflow = XMASParseSelectedProtocolWorkFlow(
    protocolOracle: SelectedProtocolOracle(protocolToFake: arguments.protocolName)
)

let bundle = Bundle(for: XMASSwiftProtocolFaker.self)
let protocolFaker = XMASSwiftProtocolFaker(bundle: bundle)
let fakeProtocolPersister = XMASFakeProtocolPersister(
    protocolFaker: protocolFaker,
    fileManager: FileManager()
)
let selectedFileOracle = SelectedSourceFileOracle(selectedSourceFilePath: arguments.fileName)

let useCase = XMASGenerateFakeForSwiftProtocolUseCase(
    alerter: TerminalAlerter(),
    logger: XMASLogger(),
    parseSelectedProtocolWorkFlow: selectedTextWorkflow,
    fakeProtocolPersister: fakeProtocolPersister,
    selectedSourceFileOracle: selectedFileOracle,
    addFileWorkflow: nil)

useCase.safelyGenerateFakeForSelectedProtocol()
