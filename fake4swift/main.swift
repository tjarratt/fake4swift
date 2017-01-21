import Foundation
import Fake4SwiftKit

let selectedFile: String
let selectedProtocol: String?

do {
    (selectedFile, selectedProtocol) = try ArgsParser(args: CommandLine.arguments).parse()
} catch let e {
    print(
        e,
        "",
        "Usage:",
        "fake4swift source_file.swift [protocol_name]",
        "",
        separator: "\n"
    )
    exit(1)
}

let selectedTextWorkflow = XMASParseSelectedProtocolWorkFlow(
    protocolOracle: SelectedProtocolOracle(protocolToFake: selectedProtocol)
)

let bundle = Bundle(for: XMASSwiftProtocolFaker.self)
let protocolFaker = XMASSwiftProtocolFaker(bundle: bundle)
let fakeProtocolPersister = XMASFakeProtocolPersister(
    protocolFaker: protocolFaker,
    fileManager: FileManager()
)
let selectedFileOracle = SelectedSourceFileOracle(selectedSourceFilePath: selectedFile)

let useCase = XMASGenerateFakeForSwiftProtocolUseCase(
    alerter: TerminalAlerter(),
    logger: XMASLogger(),
    parseSelectedProtocolWorkFlow: selectedTextWorkflow,
    fakeProtocolPersister: fakeProtocolPersister,
    selectedSourceFileOracle: selectedFileOracle,
    addFileWorkflow: nil)

useCase.safelyGenerateFakeForSelectedProtocol()
