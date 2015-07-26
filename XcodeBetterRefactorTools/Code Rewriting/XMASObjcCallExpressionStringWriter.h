#import <Foundation/Foundation.h>

@class XMASObjcMethodDeclaration;

@interface XMASObjcCallExpressionStringWriter : NSObject

- (NSString *)callExpression:(XMASObjcMethodDeclaration *)callExpression
                   forTarget:(NSString *)target
                    withArgs:(NSArray *)args
                    atColumn:(NSUInteger)column;

- (NSString *)formatInstanceMethodDeclaration:(XMASObjcMethodDeclaration *)callExpression;

@end
