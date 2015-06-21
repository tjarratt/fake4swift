#import <Foundation/Foundation.h>

@class XMASAlert;
@class XMASChangeMethodSignatureControllerProvider;
@class XMASObjcMethodDeclarationParser;

@class XMASRefactorMethodAction;

@interface XMASRefactorMethodActionProvider : NSObject

- (XMASRefactorMethodAction *)provideInstanceWithEditor:(id)editor
                                                alerter:(XMASAlert *)alerter
                                     controllerProvider:(XMASChangeMethodSignatureControllerProvider *)controllerProvider
                                       methodDeclParser:(XMASObjcMethodDeclarationParser *)methodDeclParser;

@end
