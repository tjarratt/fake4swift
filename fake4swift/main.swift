import Foundation
import BetterRefactorToolsKit

let selectedFile: String
let selectedProtocol: String?

do {
    (selectedFile, selectedProtocol) = try ArgsParser(args: Process.arguments).parse()
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

let bundle = NSBundle(forClass: XMASSwiftProtocolFaker.self)
let protocolFaker = XMASSwiftProtocolFaker(bundle: bundle)
let fakeProtocolPersister = XMASFakeProtocolPersister(
    protocolFaker: protocolFaker,
    fileManager: NSFileManager()
)

let useCase = XMASGenerateFakeForSwiftProtocolUseCase(
    alerter: TerminalAlerter(),
    logger: XMASLogger(),
    parseSelectedProtocolWorkFlow: selectedTextWorkflow,
    fakeProtocolPersister: fakeProtocolPersister,
    selectedSourceFileOracle: SelectedSourceFileOracle(selectedSourceFilePath: selectedFile))

useCase.safelyGenerateFakeForSelectedProtocol()
