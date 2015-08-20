#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "RefactorToolsModule.h"
#import "XMASRefactorMethodAction.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASAlert.h"
#import "XMASXcodeRepository.h"
#import "XMASTokenizer.h"
#import "XMASObjcMethodDeclarationParser.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InjectorSpec)

describe(@"Injector", ^{
    __block id<BSInjector, BSBinder> injector;
    __block XMASXcodeRepository *xcodeRepository;

    __block id fakeEditor;

    beforeEach(^{
        fakeEditor = [[NSObject alloc] init];
        xcodeRepository = nice_fake_for([XMASXcodeRepository class]);
        xcodeRepository stub_method(@selector(currentEditor)).and_return(fakeEditor);

        injector = (id)[Blindside injectorWithModule:[[RefactorToolsModule alloc] init]];
        [injector bind:[XMASXcodeRepository class] toInstance:xcodeRepository];
    });

    it(@"should provide a Refactor Action", ^{
        XMASRefactorMethodAction *refactorAction = [injector getInstance:[XMASRefactorMethodAction class]];
        refactorAction.alerter should be_instance_of([XMASAlert class]);
        refactorAction.tokenizer should be_instance_of([XMASTokenizer class]);
        refactorAction.methodDeclParser should be_instance_of([XMASObjcMethodDeclarationParser class]);
        refactorAction.controllerProvider should be_instance_of([XMASChangeMethodSignatureControllerProvider class]);
        refactorAction.currentEditor should be_same_instance_as(fakeEditor);
    });
});

SPEC_END
