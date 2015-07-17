#import <Foundation/Foundation.h>

@class XMASObjcCallExpressionTokenFilter;

@interface XMASObjcMethodCallParser : NSObject

- (instancetype)initWithCallExpressionTokenFilter:(XMASObjcCallExpressionTokenFilter *)callExpressionTokenFilter NS_DESIGNATED_INITIALIZER;

- (void)setupWithSelectorToMatch:(NSString *)selector
                        filePath:(NSString *)filePath
                       andTokens:(NSArray *)tokens;

- (NSArray *)matchingCallExpressions;

@end

@interface XMASObjcMethodCallParser (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end