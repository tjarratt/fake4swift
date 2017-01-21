import Foundation
import Fake4SwiftKit

@objc open class XMASImplementEquatableUseCase : NSObject {
    fileprivate(set) open var logger: XMASLogger
    fileprivate(set) open var alerter: XMASAlerter
    fileprivate(set) open var equatableWriter: XMASEquatableWriter
    fileprivate(set) open var selectedFileOracle: XMASSelectedSourceFileOracle
    dynamic fileprivate(set) open var parseStructWorkflow: XMASParseSelectedStructWorkflow

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

    @objc open func safelyAddEquatableToSelectedStruct() {
        let filePath = self.selectedFileOracle.selectedFilePath() as NSString
        if filePath.pathExtension.lowercased() != "swift" {
            self.alerter.flashMessage(
                "Select a Swift struct",
                with: .noSwiftFileSelected,
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
                    with: .noSwiftFileSelected,
                    shouldLogMessage: false
                )
            }

        } catch let error as NSError {
            self.alerter.flashComfortingMessage(forError: error)
        } catch {
            self.alerter.flashMessage(
                "Something unexpected happened",
                with: .abjectFailure,
                shouldLogMessage: true
            )
        }
    }

    fileprivate func addEquatableImplPossiblyThrowingError(_ selectedStruct : StructDeclaration) {
        do {
            try self.equatableWriter.addEquatableImplForStruct(selectedStruct)
            self.alerter.flashMessage(
                "Success!",
                with: .implementEquatable,
                shouldLogMessage: false
            )
        } catch let error as NSError {
            self.alerter.flashComfortingMessage(forError: error)
        } catch {
            self.alerter.flashMessage(
                "Something unexpected happened",
                with: .abjectFailure,
                shouldLogMessage: true
            )
        }
    }
}
