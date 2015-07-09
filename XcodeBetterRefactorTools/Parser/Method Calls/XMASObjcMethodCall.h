#import <Foundation/Foundation.h>

@interface XMASObjcMethodCall : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSelectorComponents:(NSArray *)selectorComponents
                                 arguments:(NSArray *)arguments
                                     range:(NSRange)range NS_DESIGNATED_INITIALIZER;

- (NSString *)selectorString;
- (NSRange)range;
- (NSArray *)selectorComponents;
- (NSArray *)arguments;

@end
