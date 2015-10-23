#import "XMASGenerateFakeAction.h"
#import "XMASAlert.h"
#import "XMASSelectedTextProxy.h"
#import "XMASFakeProtocolPersister.h"
#import "XMASCurrentSourceCodeDocumentProxy.h"


@interface XMASGenerateFakeAction ()
@property (nonatomic, strong) XMASAlert *alerter;
@property (nonatomic, strong) XMASSelectedTextProxy *selectedTextProxy;
@property (nonatomic, strong) XMASFakeProtocolPersister *fakeProtocolPersister;
@property (nonatomic, strong) XMASCurrentSourceCodeDocumentProxy *sourceCodeDocumentProxy;
@end

@implementation XMASGenerateFakeAction

- (instancetype)initWithAlerter:(XMASAlert *)alerter
              selectedTextProxy:(XMASSelectedTextProxy *)selectedTextProxy
          fakeProtocolPersister:(XMASFakeProtocolPersister *)fakeProtocolPersister
        sourceCodeDocumentProxy:(XMASCurrentSourceCodeDocumentProxy *)sourceCodeDocumentProxy{
    if (self = [super init]) {
        self.alerter = alerter;
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

    }
}

- (void)generateFakeForProtocolUnderCursor {
    NSString *currentFilePath = [self.sourceCodeDocumentProxy currentSourceCodeFilePath];
    if (![currentFilePath.pathExtension.lowercaseString isEqual: @"swift"]) {
        [self.alerter flashMessage:@"generate-fake only works with Swift source files"];
        return;
    }

    NSString *selectedProtocol = [self.selectedTextProxy selectedProtocolInFile:currentFilePath];
    if (!selectedProtocol) {
        [self.alerter flashMessage:@"put your cursor on a swift protocol to generate a fake for it"];
        return;
    }

    [self.alerter flashMessage:[NSString stringWithFormat:@"generating fake '%@'", selectedProtocol]];
    [self.fakeProtocolPersister persistProtocolNamed:selectedProtocol nearSourceFile:currentFilePath];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
