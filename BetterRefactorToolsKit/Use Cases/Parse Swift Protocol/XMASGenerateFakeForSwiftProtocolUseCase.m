#import <BetterRefactorToolsKit/BetterRefactorToolsKit-Swift.h>

#import "XMASGenerateFakeForSwiftProtocolUseCase.h"
#import "BetterRefactorToolsKitModule.h"
#import "XMASAlerter.h"

NSString *protocolIncludesOtherMessage = @"Unable to generate fake '%@'. It includes %lu other protocols -- this is not supported yet. Sorry!";
NSString *protocolUsesTypealiasMessage = @"Unable to generate fake '%@'. It uses a typealias -- this is not supported yet. Sorry!";


@interface XMASGenerateFakeForSwiftProtocolUseCase ()

@property (nonatomic) XMASLogger *logger;
@property (nonatomic) id<XMASAlerter> alerter;
@property (nonatomic) XMASFakeProtocolPersister *fakeProtocolPersister;
@property (nonatomic) id<XMASSelectedSourceFileOracle> selectedSourceFileOracle;
@property (nonatomic) XMASParseSelectedProtocolWorkFlow *selectedProtocolUseCase;

@end


@implementation XMASGenerateFakeForSwiftProtocolUseCase

- (instancetype)initWithAlerter:(id<XMASAlerter>)alerter
                         logger:(XMASLogger *)logger
              parseSelectedProtocolWorkFlow:(XMASParseSelectedProtocolWorkFlow *)selectedProtocolUseCase
          fakeProtocolPersister:(XMASFakeProtocolPersister *)fakeProtocolPersister
       selectedSourceFileOracle:(id<XMASSelectedSourceFileOracle>)selectedSourceFileOracle {
    if (self = [super init]) {
        self.logger = logger;
        self.alerter = alerter;
        self.fakeProtocolPersister = fakeProtocolPersister;
        self.selectedProtocolUseCase = selectedProtocolUseCase;
        self.selectedSourceFileOracle = selectedSourceFileOracle;
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
                                        nearSourceFile:currentFilePath
                                                 error:&error];
    if (error != nil) {
        [self.alerter flashComfortingMessageForError:error];
        return;
    }

    NSString *successMessage = [NSString stringWithFormat:@"Generated Fake%@ successfully!",
                         selectedProtocol.name];
    [self.alerter flashMessage:successMessage];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
