@import BetterRefactorToolsKit;

#import "XMASGenerateFakeAction.h"
#import "SwiftCompatibilityHeader.h"
#import "XMASFakeProtocolPersister.h"
#import "XMASCurrentSourceCodeDocumentProxy.h"

NSString *protocolIncludesOtherMessage = @"Unable to generate fake '%@'. It includes %lu other protocols -- this is not supported yet. Sorry!";
NSString *protocolUsesTypealiasMessage = @"Unable to generate fake '%@'. It uses a typealias -- this is not supported yet. Sorry!";


@interface XMASGenerateFakeAction ()

@property (nonatomic) XMASLogger *logger;
@property (nonatomic) id<XMASAlerter> alerter;
@property (nonatomic) XMASFakeProtocolPersister *fakeProtocolPersister;
@property (nonatomic) XMASParseSelectedProtocolUseCase *selectedProtocolUseCase;
@property (nonatomic) XMASCurrentSourceCodeDocumentProxy *sourceCodeDocumentProxy;

@end


@implementation XMASGenerateFakeAction

- (instancetype)initWithAlerter:(id<XMASAlerter>)alerter
                         logger:(XMASLogger *)logger
              selectedTextProxy:(XMASParseSelectedProtocolUseCase *)selectedProtocolUseCase
          fakeProtocolPersister:(XMASFakeProtocolPersister *)fakeProtocolPersister
        sourceCodeDocumentProxy:(XMASCurrentSourceCodeDocumentProxy *)sourceCodeDocumentProxy {
    if (self = [super init]) {
        self.logger = logger;
        self.alerter = alerter;
        self.fakeProtocolPersister = fakeProtocolPersister;
        self.selectedProtocolUseCase = selectedProtocolUseCase;
        self.sourceCodeDocumentProxy = sourceCodeDocumentProxy;
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
    NSString *currentFilePath = [self.sourceCodeDocumentProxy currentSourceCodeFilePath];
    if (![currentFilePath.pathExtension.lowercaseString isEqual: @"swift"]) {
        [self.alerter flashMessage:@"generate-fake only works with Swift source files"];
        return;
    }

    NSError *error = nil;
    ProtocolDeclaration *selectedProtocol = [self.selectedProtocolUseCase selectedProtocolInFile:currentFilePath
                                                                                           error:&error];
    if (error != nil) {
        [self.alerter flashMessage:@"put your cursor in a protocol declaration to generate a fake for it"];
        return;
    }

    if (selectedProtocol.includedProtocols.count > 0) {
        [self.alerter flashMessage:@"FAILED. Check Console.app"];

        NSString *logMessage = [NSString stringWithFormat:protocolIncludesOtherMessage,
                                selectedProtocol.name,
                                selectedProtocol.includedProtocols.count];
        [self.logger logMessage:logMessage];
        return;
    }

    if (selectedProtocol.usesTypealias) {
        [self.alerter flashMessage:@"FAILED. Check Console.app"];

        NSString *logMessage = [NSString stringWithFormat:protocolUsesTypealiasMessage,
                                selectedProtocol.name];
        [self.logger logMessage:logMessage];
        return;
    }

    [self.fakeProtocolPersister persistFakeForProtocol:selectedProtocol
                                        nearSourceFile:currentFilePath];
    NSString *success = [NSString stringWithFormat:@"Generated Fake%@ successfully!",
                         selectedProtocol.name];
    [self.alerter flashMessage:success];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
