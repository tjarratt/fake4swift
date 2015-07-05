#import "XMASIndexedSymbolRepository.h"
#import "XMASObjcSelector.h"
#import "XMASXcode.h"

@implementation XMASIndexedSymbolRepository

- (NSArray *)callExpressionsMatchingSelector:(XMASObjcSelector *)selector {
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
