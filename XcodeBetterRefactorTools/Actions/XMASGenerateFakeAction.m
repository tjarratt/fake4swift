#import "XMASGenerateFakeAction.h"
#import "XMASAlert.h"
#import "SwiftCompatibilityHeader.h"
#import "XMASFakeProtocolPersister.h"
#import "XMASCurrentSourceCodeDocumentProxy.h"
#import "XMASSelectedTextProxy.h"

NSString *unsupportedProtocolDecl = @"Unable to generate fake '%@'. It includes %lu other protocols -- this is not supported yet. Sorry!";

@interface XMASGenerateFakeAction ()
@property (nonatomic, strong) XMASAlert *alerter;
@property (nonatomic, strong) XMASLogger *logger;
@property (nonatomic, strong) id<XMASSelectedTextProxy> selectedTextProxy;
@property (nonatomic, strong) XMASFakeProtocolPersister *fakeProtocolPersister;
@property (nonatomic, strong) XMASCurrentSourceCodeDocumentProxy *sourceCodeDocumentProxy;
@end

@implementation XMASGenerateFakeAction

- (instancetype)initWithAlerter:(XMASAlert *)alerter
                         logger:(XMASLogger *)logger
              selectedTextProxy:(id <XMASSelectedTextProxy>)selectedTextProxy
          fakeProtocolPersister:(XMASFakeProtocolPersister *)fakeProtocolPersister
        sourceCodeDocumentProxy:(XMASCurrentSourceCodeDocumentProxy *)sourceCodeDocumentProxy {
    if (self = [super init]) {
        self.alerter = alerter;
        self.logger = logger;
        self.selectedTextProxy = selectedTextProxy;
        self.fakeProtocolPersister = fakeProtocolPersister;
        self.sourceCodeDocumentProxy = sourceCodeDocumentProxy;
    }

    return self;
}

- (void)safelyGenerateFakeForProtocolUnderCursor {
    @try {
        [self generateFakeForProtocolUnderCursor];
    } @catch (NSException *e) {
        [self.alerter flashComfortingMessageForException:e];
    }
}

- (void)generateFakeForProtocolUnderCursor {
    NSString *currentFilePath = [self.sourceCodeDocumentProxy currentSourceCodeFilePath];
    if (![currentFilePath.pathExtension.lowercaseString isEqual: @"swift"]) {
        [self.alerter flashMessage:@"generate-fake only works with Swift source files"];
        return;
    }

    ProtocolDeclaration *selectedProtocol = [self.selectedTextProxy selectedProtocolInFile:currentFilePath];
    if (!selectedProtocol || [selectedProtocol.name isEqualToString:@""]) {
        [self.alerter flashMessage:@"put your cursor on a swift protocol to generate a fake for it"];
        return;
    }

    if (selectedProtocol.includedProtocols.count > 0) {
        [self.alerter flashMessage:@"FAILED. Check Console.app"];

        NSString *logMessage = [[NSString alloc] initWithFormat:unsupportedProtocolDecl, selectedProtocol.name, selectedProtocol.includedProtocols.count];
        [self.logger logMessage:logMessage];
        return;
    }

    [self.fakeProtocolPersister persistFakeForProtocol:selectedProtocol nearSourceFile:currentFilePath];
    [self.alerter flashMessage:[NSString stringWithFormat:@"Generated Fake%@ successfully!", selectedProtocol.name]];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
