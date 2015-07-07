#import <Foundation/Foundation.h>

@interface XMASObjcMethodCallParser : NSObject

- (NSArray *)parseMethodCallsFromTokens:(NSArray *)tokens
                       matchingSelector:(NSString *)selectorName;

@end
