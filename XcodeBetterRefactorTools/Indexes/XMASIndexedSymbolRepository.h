#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

@class XMASObjcMethodDeclaration;

@interface XMASIndexedSymbolRepository : NSObject

- (void)changeCallsite:(XC(IDEIndexSymbol))callsite
            fromMethod:(XMASObjcMethodDeclaration *)oldSelector
           toNewMethod:(XMASObjcMethodDeclaration *)newSelector;

- (NSArray *)callExpressionsMatchingSelector:(XMASObjcMethodDeclaration *)selector;

@end
