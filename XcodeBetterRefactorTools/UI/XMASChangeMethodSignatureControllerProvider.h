#import <Foundation/Foundation.h>
#import "XMASChangeMethodSignatureController.h"

@class XMASAlert;
@class XMASWindowProvider;
@class XMASMethodOccurrencesRepository;
@class XMASObjcCallExpressionRewriter;
@class XMASObjcMethodDeclarationRewriter;
@class XMASObjcMethodDeclarationStringWriter;

@protocol XMASChangeMethodSignatureControllerDelegate;

@interface XMASChangeMethodSignatureControllerProvider : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                               alerter:(id<XMASAlerter>)alerter
               methodOccurrencesRepository:(XMASMethodOccurrencesRepository *)methodOccurrencesRepository
                callExpressionRewriter:(XMASObjcCallExpressionRewriter *)callExpressionRewriter
         methodDeclarationStringWriter:(XMASObjcMethodDeclarationStringWriter *)methodDeclarationStringWriter
             methodDeclarationRewriter:(XMASObjcMethodDeclarationRewriter *)methodDeclarationRewriter NS_DESIGNATED_INITIALIZER;

- (XMASChangeMethodSignatureController *)provideInstanceWithDelegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate;

@end
