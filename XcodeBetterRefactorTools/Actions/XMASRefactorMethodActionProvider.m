#import "XMASRefactorMethodActionProvider.h"
#import "XMASAlert.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASRefactorMethodAction.h"

static XMASRefactorMethodAction *action;

@implementation XMASRefactorMethodActionProvider

- (XMASRefactorMethodAction *)provideInstanceWithEditor:(id)editor
                                                alerter:(XMASAlert *)alerter
                                     controllerProvider:(XMASChangeMethodSignatureControllerProvider *)controllerProvider
                                       methodDeclParser:(XMASObjcMethodDeclarationParser *)methodDeclParser
{
    if (action != nil) {
        return action;
    }
    
    action = [[XMASRefactorMethodAction alloc] initWithEditor:editor
                                                      alerter:alerter
                                           controllerProvider:controllerProvider
                                             methodDeclParser:methodDeclParser];

    return action;
}

@end
