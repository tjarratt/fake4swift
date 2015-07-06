#import "XMASIndexedSymbolRepository.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASXcode.h"

@implementation XMASIndexedSymbolRepository

- (void)changeCallsite:(XC(IDEIndexSymbol))callsite
            fromMethod:(XMASObjcMethodDeclaration *)oldSelector
           toNewMethod:(XMASObjcMethodDeclaration *)newSelector {
    
}

- (NSArray *)callExpressionsMatchingSelector:(XMASObjcMethodDeclaration *)selector {
    XC(IDEIndex) index = [XMASXcode indexForCurrentWorkspace];
    id callableKind = [XMASXcode instanceMethodSymbolKind];

    NSString *selectorToReplace = selector.selectorString;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *symbols = [index allSymbolsMatchingKind:callableKind workspaceOnly:YES];
    for (id symbol in symbols) {
        if ([selectorToReplace isEqualToString:[symbol valueForKey:@"name"]]) {
            [results addObject:symbol];
        }
    }

    return results;
}

@end
