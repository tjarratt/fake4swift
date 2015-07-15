#import <Foundation/Foundation.h>

@interface XMASObjcCallExpressionTokenFilter : NSObject

- (NSSet *)parseCallExpressionRangesFromTokens:(NSArray *)tokens;

@end
