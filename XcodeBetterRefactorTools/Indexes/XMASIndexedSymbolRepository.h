#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

@class XMASObjcMethodDeclaration;

@interface XMASIndexedSymbolRepository : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWorkspaceWindowController:(XC(IDEWorkspaceWindowController))workspaceWindowController NS_DESIGNATED_INITIALIZER;
- (NSArray *)callExpressionsMatchingSelector:(XMASObjcMethodDeclaration *)selector;

@end
