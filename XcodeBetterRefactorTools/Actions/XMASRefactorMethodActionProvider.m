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
        [action setupWithEditor:editor];
        return action;
    }
    
    action = [[XMASRefactorMethodAction alloc] initWithAlerter:alerter
                                            controllerProvider:controllerProvider
                                              methodDeclParser:methodDeclParser];

    [action setupWithEditor:editor];

    return action;
}

@end
