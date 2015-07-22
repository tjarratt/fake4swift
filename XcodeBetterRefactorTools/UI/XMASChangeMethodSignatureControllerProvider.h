#import <Foundation/Foundation.h>

@class XMASAlert;
@class XMASWindowProvider;
@class XMASIndexedSymbolRepository;
@class XMASObjcCallExpressionRewriter;
@class XMASChangeMethodSignatureController;

@protocol XMASChangeMethodSignatureControllerDelegate;

@interface XMASChangeMethodSignatureControllerProvider : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                               alerter:(XMASAlert *)alerter
               indexedSymbolRepository:(XMASIndexedSymbolRepository *)indexedSymbolRepository
                callExpressionRewriter:(XMASObjcCallExpressionRewriter *)callExpressionRewriter NS_DESIGNATED_INITIALIZER;

- (XMASChangeMethodSignatureController *)provideInstanceWithDelegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate;

@end