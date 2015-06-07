#import <Foundation/Foundation.h>

@interface XMASObjcMethodDeclarationParser : NSObject

- (NSArray *)parseMethodDeclarationsFromTokens:(NSArray *)tokens;

@end
