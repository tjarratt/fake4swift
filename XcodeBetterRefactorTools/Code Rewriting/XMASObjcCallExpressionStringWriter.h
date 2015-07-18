#import <Foundation/Foundation.h>

@class XMASObjcMethodDeclaration;

@interface XMASObjcCallExpressionStringWriter : NSObject

- (NSString *)callExpression:(XMASObjcMethodDeclaration *)callExpression
                   forTarget:(NSString *)target
                    withArgs:(NSArray *)args;

@end
