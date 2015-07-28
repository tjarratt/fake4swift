#import <Foundation/Foundation.h>

@class XMASObjcMethodDeclaration;
@class XMASObjcMethodDeclarationStringWriter;

@interface XMASObjcMethodDeclarationRewriter : NSObject

- (instancetype)initWithMethodDeclarationStringWriter:(XMASObjcMethodDeclarationStringWriter *)methodDeclarationStringWriter NS_DESIGNATED_INITIALIZER;
- (void)changeMethodDeclaration:(XMASObjcMethodDeclaration *)oldMethodDeclaration
                    toNewMethod:(XMASObjcMethodDeclaration *)newMethodDeclaration
                         inFile:(NSString *)filePath;

@end

@interface XMASObjcMethodDeclarationRewriter (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end
