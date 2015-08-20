#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

@class XMASObjcMethodDeclaration;
@class XMASXcodeRepository;

@interface XMASMethodOccurrencesRepository : NSObject

- (instancetype)initWithWorkspaceWindowController:(XC(IDEWorkspaceWindowController))workspaceWindowController
                                  xcodeRepository:(XMASXcodeRepository *)xcodeRepository NS_DESIGNATED_INITIALIZER;

- (NSSet *)callSitesOfCurrentlySelectedMethod;
- (NSSet *)forwardDeclarationsOfMethod:(XMASObjcMethodDeclaration *)methodDeclaration;

@end

@interface XMASMethodOccurrencesRepository (UnavailableInitializers)
- (instancetype)init NS_UNAVAILABLE;
@end
