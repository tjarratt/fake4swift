#import <Foundation/Foundation.h>
#import <ClangKit/ClangKit.h>

@interface XMASObjcSelector : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTokens:(NSArray *)tokens;
- (instancetype)initWithSelectorComponents:(NSArray *)selectorComponents
                                parameters:(NSArray *)parameters
                                returnType:(NSString *)returnType
                                     range:(NSRange)range;

- (NSArray *)parameters;
- (NSString *)selectorString;
- (NSArray *)components;
- (NSString *)returnType;
- (NSRange)range;

- (instancetype)deleteComponentAtIndex:(NSUInteger)index;
- (instancetype)insertComponentAtIndex:(NSUInteger)index;
- (instancetype)swapComponentAtIndex:(NSUInteger)index withComponentAtIndex:(NSUInteger)otherIndex;

- (instancetype)changeSelectorNameAtIndex:(NSUInteger)index to:(NSString *)newType;
- (instancetype)changeParameterTypeAtIndex:(NSUInteger)index to:(NSString *)newType;
- (instancetype)changeParameterLocalNameAtIndex:(NSUInteger)index to:(NSString *)newName;

@end
