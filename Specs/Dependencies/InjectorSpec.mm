#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "RefactorToolsModule.h"
#import "XMASRefactorMethodAction.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASAlert.h"
#import "XMASXcode.h"
#import "XMASTokenizer.h"
#import "XMASObjcMethodDeclarationParser.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InjectorSpec)

describe(@"Injector", ^{
    __block id<BSInjector> injector;

    __block id fakeEditor;

    beforeEach(^{
        spy_on([XMASXcode class]);
        fakeEditor = [[NSObject alloc] init];
        [XMASXcode class] stub_method(@selector(currentEditor)).and_return(fakeEditor);
    });

    afterEach(^{
        stop_spying_on([XMASXcode class]);
    });

    beforeEach(^{
        injector = [Blindside injectorWithModule:[[RefactorToolsModule alloc] init]];
    });

    it(@"should provide a Refactor Action", ^{
        XMASRefactorMethodAction *refactorAction = [injector getInstance:[XMASRefactorMethodAction class]];
        refactorAction.alerter should be_instance_of([XMASAlert class]);
        refactorAction.tokenizer should be_instance_of([XMASTokenizer class]);
        refactorAction.methodDeclParser should be_instance_of([XMASObjcMethodDeclarationParser class]);
        refactorAction.controllerProvider should be_instance_of([XMASChangeMethodSignatureControllerProvider class]);
        

        refactorAction.currentEditor should_not be_nil;
    });
});

SPEC_END
