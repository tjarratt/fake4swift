#import <Foundation/Foundation.h>
#import "XMASChangeMethodSignatureController.h"

@class XMASAlert;
@class XMASWindowProvider;
@class XMASIndexedSymbolRepository;
@class XMASObjcCallExpressionRewriter;
@class XMASObjcMethodDeclarationRewriter;
@class XMASObjcMethodDeclarationStringWriter;

@protocol XMASChangeMethodSignatureControllerDelegate;

@interface XMASChangeMethodSignatureControllerProvider : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                               alerter:(XMASAlert *)alerter
               indexedSymbolRepository:(XMASIndexedSymbolRepository *)indexedSymbolRepository
                callExpressionRewriter:(XMASObjcCallExpressionRewriter *)callExpressionRewriter
         methodDeclarationStringWriter:(XMASObjcMethodDeclarationStringWriter *)methodDeclarationStringWriter
             methodDeclarationRewriter:(XMASObjcMethodDeclarationRewriter *)methodDeclarationRewriter NS_DESIGNATED_INITIALIZER;

- (XMASChangeMethodSignatureController *)provideInstanceWithDelegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate;

@end
