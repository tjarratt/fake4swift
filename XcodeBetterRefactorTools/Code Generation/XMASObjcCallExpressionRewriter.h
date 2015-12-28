#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

@class XMASAlert;
@class XMASTokenizer;
@class XMASObjcMethodCallParser;
@class XMASObjcMethodDeclaration;
@class XMASObjcCallExpressionStringWriter;

@interface XMASObjcCallExpressionRewriter : NSObject

@property (nonatomic, readonly) XMASObjcMethodCallParser *methodCallParser;

- (instancetype)initWithAlerter:(id<XMASAlerter>)alerter
                      tokenizer:(XMASTokenizer *)tokenizer
           callExpressionParser:(XMASObjcMethodCallParser *)callExpressionParser
     callExpressionStringWriter:(XMASObjcCallExpressionStringWriter *)callExpressionStringWriter NS_DESIGNATED_INITIALIZER;

- (void)changeCallsite:(XC(IDEIndexSymbol))callsite
            fromMethod:(XMASObjcMethodDeclaration *)oldSelector
           toNewMethod:(XMASObjcMethodDeclaration *)newSelector;

@end

@interface XMASObjcCallExpressionRewriter (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end
