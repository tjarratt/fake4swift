#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "RefactorToolsModule.h"
#import "XMASRefactorMethodAction.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASAlert.h"
#import "XMASXcodeRepository.h"
#import "XMASTokenizer.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASGenerateFakeAction.h"
#import "XMASFakeProtocolPersister.h"
#import "XMASCurrentSourceCodeDocumentProxy.h"
#import "Specs-Swift.h"

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

    it(@"should provide a Generate Fake Action", ^{
        XMASGenerateFakeAction *generateFakeAction = [injector getInstance:[XMASGenerateFakeAction class]];
        generateFakeAction.alerter should be_instance_of([XMASAlert class]);
        generateFakeAction.logger should be_instance_of([XMASLogger class]);
        generateFakeAction.selectedTextProxy should conform_to(@protocol(XMASSelectedTextProxy));
        generateFakeAction.fakeProtocolPersister should be_instance_of([XMASFakeProtocolPersister class]);
        generateFakeAction.sourceCodeDocumentProxy should be_instance_of([XMASCurrentSourceCodeDocumentProxy class]);
    });

    it(@"should provide a Swift Protocol Faker", ^{
        XMASSwiftProtocolFaker *protocolFaker = [injector getInstance:[XMASSwiftProtocolFaker class]];
        protocolFaker should be_instance_of([XMASSwiftProtocolFaker class]);
    });

    it(@"should provide a Logger", ^{
        XMASLogger *logger = [injector getInstance:[XMASLogger class]];
        logger should_not be_nil;
        logger should be_instance_of([XMASLogger class]);
    });

    it(@"should provide a fake protocol persister", ^{
        XMASFakeProtocolPersister *fakeProtocolPersister = [injector getInstance:[XMASFakeProtocolPersister class]];
        fakeProtocolPersister.protocolFaker should be_instance_of([XMASSwiftProtocolFaker class]);
        fakeProtocolPersister.fileManager should be_instance_of([NSFileManager class]);
    });
});

SPEC_END
