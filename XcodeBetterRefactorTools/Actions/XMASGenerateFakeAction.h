#import <Foundation/Foundation.h>

@class XMASAlert;
@class XMASLogger;
@class XMASSelectedTextProxy;
@class XMASFakeProtocolPersister;
@class XMASParseSelectedProtocolUseCase;

@protocol XMASSelectedSourceFileOracle;

NS_ASSUME_NONNULL_BEGIN

@interface XMASGenerateFakeAction : NSObject

- (instancetype)initWithAlerter:(id<XMASAlerter>)alerter
                         logger:(XMASLogger *)logger
              selectedTextProxy:(XMASParseSelectedProtocolUseCase *)selectedProtocolUseCase
          fakeProtocolPersister:(XMASFakeProtocolPersister *)fakeProtocolPersister
       selectedSourceFileOracle:(id<XMASSelectedSourceFileOracle>)selectedSourceFileOracle NS_DESIGNATED_INITIALIZER;

- (void)safelyGenerateFakeForSelectedProtocol;

@property (nonatomic, readonly) XMASLogger *logger;
@property (nonatomic, readonly) id<XMASAlerter> alerter;
@property (nonatomic, readonly) XMASFakeProtocolPersister *fakeProtocolPersister;
@property (nonatomic, readonly) id<XMASSelectedSourceFileOracle> selectedSourceFileOracle;
@property (nonatomic, readonly) XMASParseSelectedProtocolUseCase *selectedProtocolUseCase;

@end

@interface XMASGenerateFakeAction (UnavailableInitializers)

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END;
