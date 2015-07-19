#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

@class XMASObjcMethodDeclaration;

@interface XMASIndexedSymbolRepository : NSObject

- (NSArray *)callExpressionsMatchingSelector:(XMASObjcMethodDeclaration *)selector;

@end
