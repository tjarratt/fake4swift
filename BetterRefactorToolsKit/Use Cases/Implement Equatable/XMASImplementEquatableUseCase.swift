import Foundation
import BetterRefactorToolsKit

@objc public class XMASImplementEquatableUseCase : NSObject {
    private(set) public var logger: XMASLogger
    private(set) public var alerter: XMASAlerter
    private(set) public var equatableWriter: XMASEquatableWriter
    private(set) public var selectedFileOracle: XMASSelectedSourceFileOracle
    dynamic private(set) public var parseStructWorkflow: XMASParseSelectedStructWorkflow

    @objc public init(
        logger: XMASLogger,
        alerter: XMASAlerter,
        equatableWriter: XMASEquatableWriter,
        selectedFileOracle: XMASSelectedSourceFileOracle,
        parseStructWorkflow: XMASParseSelectedStructWorkflow) {
            self.logger = logger
            self.alerter = alerter
            self.equatableWriter = equatableWriter
            self.selectedFileOracle = selectedFileOracle
            self.parseStructWorkflow = parseStructWorkflow
    }

    @objc public func safelyAddEquatableToSelectedStruct() {
        let filePath = self.selectedFileOracle.selectedFilePath() as NSString
        if filePath.pathExtension.lowercaseString != "swift" {
            self.alerter.flashMessage(
                "Select a Swift struct",
                withImage: .NoSwiftFileSelected,
                shouldLogMessage: false
            )
        }

        do {
            let maybeStruct : StructDeclaration? = try
                self.parseStructWorkflow.selectedStructInFile(filePath as String)

            if let selectedStruct = maybeStruct {
                addEquatableImplPossiblyThrowingError(selectedStruct)
            } else {
                self.alerter.flashMessage(
                    "Select a swift struct",
                    withImage: .NoSwiftFileSelected,
                    shouldLogMessage: false
                )
            }

        } catch let error as NSError {
            self.alerter.flashComfortingMessageForError(error)
        } catch {
            self.alerter.flashMessage(
                "Something unexpected happened",
                withImage: .AbjectFailure,
                shouldLogMessage: true
            )
        }
    }

    private func addEquatableImplPossiblyThrowingError(selectedStruct : StructDeclaration) {
        do {
            try self.equatableWriter.addEquatableImplForStruct(selectedStruct)
            self.alerter.flashMessage(
                "Success!",
                withImage: .ImplementEquatable,
                shouldLogMessage: false
            )
        } catch let error as NSError {
            self.alerter.flashComfortingMessageForError(error)
        } catch {
            self.alerter.flashMessage(
                "Something unexpected happened",
                withImage: .AbjectFailure,
                shouldLogMessage: true
            )
        }
    }
}