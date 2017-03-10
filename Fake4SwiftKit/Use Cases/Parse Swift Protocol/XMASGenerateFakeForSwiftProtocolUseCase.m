#import <Fake4SwiftKit/Fake4SwiftKit.h>
#import <Fake4SwiftKit/Fake4SwiftKit-Swift.h>

#import "XMASGenerateFakeForSwiftProtocolUseCase.h"
#import "Fake4SwiftKitModule.h"
#import "XMASAlerter.h"

NSString *protocolIncludesOtherMessage = @"Unable to generate fake '%@'. It includes %lu other protocols -- this is not supported yet. Sorry!";
NSString *protocolUsesTypealiasMessage = @"Unable to generate fake '%@'. It uses a typealias -- this is not supported yet. Sorry!";


@interface XMASGenerateFakeForSwiftProtocolUseCase ()

@property (nonatomic) XMASLogger *logger;
@property (nonatomic) id<XMASAlerter> alerter;
@property (nonatomic) XMASFakeProtocolPersister *fakeProtocolPersister;
@property (nonatomic) id<XMASSelectedSourceFileOracle> selectedSourceFileOracle;
@property (nonatomic) XMASParseSelectedProtocolWorkFlow *selectedProtocolWorkFlow;
@property (nonatomic, nullable) id<XMASAddFileToXcodeProjectWorkflow> addFileWorkflow;

@end


@implementation XMASGenerateFakeForSwiftProtocolUseCase

- (instancetype)initWithAlerter:(id<XMASAlerter>)alerter
                         logger:(XMASLogger *)logger
  parseSelectedProtocolWorkFlow:(XMASParseSelectedProtocolWorkFlow *)selectedProtocolWorkFlow
          fakeProtocolPersister:(XMASFakeProtocolPersister *)fakeProtocolPersister
       selectedSourceFileOracle:(id<XMASSelectedSourceFileOracle>)selectedSourceFileOracle
                addFileWorkflow:(id<XMASAddFileToXcodeProjectWorkflow>)addFileWorkflow {
    if (self = [super init]) {
        self.logger = logger;
        self.alerter = alerter;
        self.fakeProtocolPersister = fakeProtocolPersister;
        self.selectedProtocolWorkFlow = selectedProtocolWorkFlow;
        self.selectedSourceFileOracle = selectedSourceFileOracle;
        self.addFileWorkflow = addFileWorkflow;
    }

    return self;
}

- (void)safelyGenerateFakeForSelectedProtocol {
    @try {
        [self generateFakeForSelectedProtocol];
    } @catch (NSException *e) {
        [self.alerter flashComfortingMessageForException:e];
    }
}

- (void)generateFakeForSelectedProtocol {
    NSString *currentFilePath = [self.selectedSourceFileOracle selectedFilePath];
    if (![currentFilePath.pathExtension.lowercaseString isEqual: @"swift"]) {
        [self.alerter flashMessage:@"Select a Swift protocol"
                         withImage:XMASAlertImageNoSwiftFileSelected
                  shouldLogMessage:NO];
        return;
    }

    NSError *error = nil;
    ProtocolDeclaration *selectedProtocol = [self.selectedProtocolWorkFlow selectedProtocolInFile:currentFilePath
                                                                                            error:&error];
    if (error != nil) {
        [self.alerter flashComfortingMessageForError:error];
        return;
    }

    if (selectedProtocol.includedProtocols.count > 0) {
        [self.alerter flashMessage:@"Check Console.app"
                         withImage:XMASAlertImageAbjectFailure
                  shouldLogMessage:NO];

        NSString *logMessage = [NSString stringWithFormat:protocolIncludesOtherMessage,
                                selectedProtocol.name,
                                selectedProtocol.includedProtocols.count];
        [self.logger logMessage:logMessage];
        return;
    }

    if (selectedProtocol.usesTypealias) {
        [self.alerter flashMessage:@"Check Console.app"
                         withImage:XMASAlertImageAbjectFailure
                  shouldLogMessage:NO];

        NSString *logMessage = [NSString stringWithFormat:protocolUsesTypealiasMessage,
                                selectedProtocol.name];
        [self.logger logMessage:logMessage];
        return;
    }

    FakeProtocolPersistResults *results = [self.fakeProtocolPersister persistFakeForProtocol:selectedProtocol
                                                                              nearSourceFile:currentFilePath
                                                                                       error:&error];
    if (error != nil) {
        [self.alerter flashComfortingMessageForError:error];
        return;
    }

    [self.addFileWorkflow addFileToXcode:results.pathToFake
                      alongsideFileNamed:currentFilePath
                               directory:results.directoryName
                                   error:&error];
    if (error != nil) {
        [self.alerter flashComfortingMessageForError:error];
        return;
    }

    [self.alerter flashMessage:@"Success!"
                     withImage:XMASAlertImageGeneratedFake
              shouldLogMessage:NO];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
