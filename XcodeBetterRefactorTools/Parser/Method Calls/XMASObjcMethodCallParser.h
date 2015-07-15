#import <Foundation/Foundation.h>

@interface XMASObjcMethodCallParser : NSObject

- (instancetype)initWithSelectorToMatch:(NSString *)selector
                             inFilePath:(NSString *)filePath
                             withTokens:(NSArray *)tokens NS_DESIGNATED_INITIALIZER;

- (NSArray *)matchingCallExpressions;

@end

@interface XMASObjcMethodCallParser (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end