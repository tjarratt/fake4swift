#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

@class XMASAlert;
@class XMASTokenizer;
@class XMASObjcMethodDeclaration;
@class XMASObjcMethodDeclarationParser;
@class XMASObjcMethodDeclarationStringWriter;

@interface XMASObjcMethodDeclarationRewriter : NSObject

- (instancetype)initWithMethodDeclarationStringWriter:(XMASObjcMethodDeclarationStringWriter *)methodDeclarationStringWriter
                              methodDeclarationParser:(XMASObjcMethodDeclarationParser *)methodDeclarationParser
                                            tokenizer:(XMASTokenizer *)tokenizer
                                              alerter:(id<XMASAlerter>)alerter NS_DESIGNATED_INITIALIZER;

- (void)changeMethodDeclaration:(XMASObjcMethodDeclaration *)oldMethodDeclaration
                    toNewMethod:(XMASObjcMethodDeclaration *)newMethodDeclaration
                         inFile:(NSString *)filePath;
- (void)changeMethodDeclarationForSymbol:(XC(IDEIndexSymbol))symbol
                                toMethod:(XMASObjcMethodDeclaration *)newMethodDeclaration;

@end

@interface XMASObjcMethodDeclarationRewriter (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end
