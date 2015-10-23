#import <Foundation/Foundation.h>

@class XMASAlert;
@class XMASSelectedTextProxy;
@class XMASFakeProtocolPersister;
@class XMASCurrentSourceCodeDocumentProxy;

@interface XMASGenerateFakeAction : NSObject

- (instancetype)initWithAlerter:(XMASAlert *)alerter
              selectedTextProxy:(XMASSelectedTextProxy *)selectedTextProxy
          fakeProtocolPersister:(XMASFakeProtocolPersister *)fakeProtocolPersister
        sourceCodeDocumentProxy:(XMASCurrentSourceCodeDocumentProxy *)sourceCodeDocumentProxy NS_DESIGNATED_INITIALIZER;
- (void)safelyGenerateFakeForProtocolUnderCursor;

@end

@interface XMASGenerateFakeAction (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end
