#import "XMASRefactorMethodActionProvider.h"
#import "XMASAlert.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASRefactorMethodAction.h"
#import "XMASTokenizer.h"
#import "XMASXcodeTargetSearchPathResolver.h"
#import "XMASSearchPathExpander.h"

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


    XMASSearchPathExpander *searchPathExpander = [[XMASSearchPathExpander alloc] init];
    XMASXcodeTargetSearchPathResolver *searchPathResolver = [[XMASXcodeTargetSearchPathResolver alloc] initWithPathExpander:searchPathExpander];
    XMASTokenizer *tokenizer = [[XMASTokenizer alloc] initWithTargetSearchPathResolver:searchPathResolver];
    
    action = [[XMASRefactorMethodAction alloc] initWithAlerter:alerter
                                                     tokenizer:tokenizer
                                            controllerProvider:controllerProvider
                                              methodDeclParser:methodDeclParser];

    [action setupWithEditor:editor];

    return action;
}

@end
