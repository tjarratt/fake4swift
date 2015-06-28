#import <Cedar/Cedar.h>
#import "XMASRefactorMethodActionProvider.h"
#import "XMASAlert.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASRefactorMethodAction.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASRefactorMethodActionProviderSpec)

describe(@"XMASRefactorMethodActionProvider", ^{
    __block XMASRefactorMethodActionProvider *subject;

    beforeEach(^{
        subject = [[XMASRefactorMethodActionProvider alloc] init];
    });

    describe(@"providing an instance of a change method signature action", ^{
        __block id editor;
        __block XMASAlert *alerter;
        __block XMASChangeMethodSignatureControllerProvider *controllerProvider;
        __block XMASObjcMethodDeclarationParser *methodDeclParser;

        __block XMASRefactorMethodAction *action;

        beforeEach(^{
            editor = nice_fake_for([NSObject class]);
            alerter = nice_fake_for([XMASAlert class]);
            controllerProvider = nice_fake_for([XMASChangeMethodSignatureControllerProvider class]);
            methodDeclParser = nice_fake_for([XMASObjcMethodDeclarationParser class]);

            action = [subject provideInstanceWithEditor:editor
                                                alerter:alerter
                                     controllerProvider:controllerProvider
                                       methodDeclParser:methodDeclParser];
        });

        it(@"should yield a RefactorMethodAction", ^{
            action should be_instance_of([XMASRefactorMethodAction class]);
        });

        it(@"should configure the RefactorMethodAction with the editor", ^{
            action.currentEditor should be_same_instance_as(editor);
        });

        it(@"should have a singleton reference to its refactor action", ^{
            XMASRefactorMethodAction *anotherAction = [subject provideInstanceWithEditor:editor
                                                                                          alerter:alerter
                                                                               controllerProvider:controllerProvider
                                                                                 methodDeclParser:methodDeclParser];
            anotherAction should be_same_instance_as(action);
            anotherAction.currentEditor should be_same_instance_as(editor);
        });
    });
});

SPEC_END
