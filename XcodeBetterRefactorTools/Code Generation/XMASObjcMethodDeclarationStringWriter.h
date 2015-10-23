#import <Foundation/Foundation.h>

@class XMASObjcMethodDeclaration;

@interface XMASObjcMethodDeclarationStringWriter : NSObject

- (NSString *)formatInstanceMethodDeclaration:(XMASObjcMethodDeclaration *)callExpression;

@end
