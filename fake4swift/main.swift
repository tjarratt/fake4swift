import Foundation
import BetterRefactorToolsKit

let alerter = TerminalAlerter.init()
let logger = XMASLogger.init()
let bundle = NSBundle.init(forClass: XMASSwiftProtocolFaker.self)

let selectedProtocolOracle = SelectedProtocolFromArgs.init()
let selectedTextWorkflow = XMASParseSelectedProtocolWorkFlow.init(
    protocolOracle: selectedProtocolOracle
)

let protocolFaker = XMASSwiftProtocolFaker.init(bundle: bundle)
let fakeProtocolPersister = XMASFakeProtocolPersister.init(
    protocolFaker: protocolFaker,
    fileManager: NSFileManager.init()
)

let selectedFileOracle = SelectedClassFromArgs.init()

let useCase = XMASGenerateFakeForSwiftProtocolUseCase.init(
    alerter: alerter,
    logger: logger,
    parseSelectedProtocolWorkFlow: selectedTextWorkflow,
    fakeProtocolPersister: fakeProtocolPersister,
    selectedSourceFileOracle: selectedFileOracle)

useCase.safelyGenerateFakeForSelectedProtocol()
