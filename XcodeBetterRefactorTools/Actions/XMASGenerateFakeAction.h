#import <Foundation/Foundation.h>

@class XMASAlert;
@class XMASLogger;
@class XMASSelectedTextProxy;
@class XMASFakeProtocolPersister;
@class XMASParseSelectedProtocolUseCase;
@class XMASCurrentSourceCodeDocumentProxy;


NS_ASSUME_NONNULL_BEGIN

@interface XMASGenerateFakeAction : NSObject

- (instancetype)initWithAlerter:(id<XMASAlerter>)alerter
                         logger:(XMASLogger *)logger
              selectedTextProxy:(XMASParseSelectedProtocolUseCase *)selectedProtocolUseCase
          fakeProtocolPersister:(XMASFakeProtocolPersister *)fakeProtocolPersister
        sourceCodeDocumentProxy:(XMASCurrentSourceCodeDocumentProxy *)sourceCodeDocumentProxy NS_DESIGNATED_INITIALIZER;
- (void)safelyGenerateFakeForSelectedProtocol;

@property (nonatomic, strong, readonly) id<XMASAlerter> alerter;
@property (nonatomic, strong, readonly) XMASLogger *logger;
@property (nonatomic, strong, readonly) XMASParseSelectedProtocolUseCase *selectedProtocolUseCase;
@property (nonatomic, strong, readonly) XMASFakeProtocolPersister *fakeProtocolPersister;
@property (nonatomic, strong, readonly) XMASCurrentSourceCodeDocumentProxy *sourceCodeDocumentProxy;

@end

@interface XMASGenerateFakeAction (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END;
