#import <Foundation/Foundation.h>

@class XMASObjcSelector;

@interface XMASIndexedSymbolRepository : NSObject

- (NSArray *)callExpressionsMatchingSelector:(XMASObjcSelector *)selector;

@end
