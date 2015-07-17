#import <Foundation/Foundation.h>

@interface XMASObjcMethodCall : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSelectorComponents:(NSArray *)selectorComponents
                              columnNumber:(NSUInteger)columnNumber
                                lineNumber:(NSUInteger)lineNumber
                                 arguments:(NSArray *)arguments
                                  filePath:(NSString *)filePath
                                    target:(NSString *)target
                                     range:(NSRange)range NS_DESIGNATED_INITIALIZER;

- (NSArray *)selectorComponents;
- (NSString *)selectorString;
- (NSUInteger)columnNumber;
- (NSUInteger)lineNumber;
- (NSString *)filePath;
- (NSArray *)arguments;
- (NSString *)target;
- (NSRange)range;

@end
