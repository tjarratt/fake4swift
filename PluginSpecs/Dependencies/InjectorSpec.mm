#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit-Swift.h>

#import "RefactorToolsModule.h"

#import "XMASTokenizer.h"
#import "PluginSpecs-Swift.h"
#import "XMASXcodeRepository.h"
#import "XMASGenerateFakeAction.h"
#import "XMASRefactorMethodAction.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASCurrentSourceCodeDocumentProxy.h"
#import "XMASChangeMethodSignatureControllerProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InjectorSpec)

describe(@"the better refactor tools Xcode Plugin module", ^{
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
        refactorAction.alerter should conform_to(@protocol(XMASAlerter));
        refactorAction.tokenizer should be_instance_of([XMASTokenizer class]);
        refactorAction.methodDeclParser should be_instance_of([XMASObjcMethodDeclarationParser class]);
        refactorAction.controllerProvider should be_instance_of([XMASChangeMethodSignatureControllerProvider class]);
        refactorAction.currentEditor should be_same_instance_as(fakeEditor);
    });

    it(@"should provide a Generate Fake Action", ^{
        XMASGenerateFakeAction *generateFakeAction = [injector getInstance:[XMASGenerateFakeAction class]];
        generateFakeAction.alerter should conform_to(@protocol(XMASAlerter));
        generateFakeAction.logger should be_instance_of([XMASLogger class]);
        generateFakeAction.selectedProtocolUseCase should be_instance_of([XMASParseSelectedProtocolUseCase class]);
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
        fakeProtocolPersister.protocolFaker should conform_to(@protocol(XMASSwiftProtocolFaking));
        fakeProtocolPersister.fileManager should conform_to(@protocol(XMASFileManager));
    });

    it(@"should provide a use case to parse a selected swift protocol from a file", ^{
        XMASParseSelectedProtocolUseCase *selectedProtocolUseCase = [injector getInstance:[XMASParseSelectedProtocolUseCase class]];
        selectedProtocolUseCase should_not be_nil;
        selectedProtocolUseCase.selectedProtocolOracle should conform_to(@protocol(XMASSelectedProtocolOracle));
    });

    it(@"should have a selected protocol oracle", ^{
        id oracle = [injector getInstance:@protocol(XMASSelectedProtocolOracle)];
        oracle should_not be_nil;
        oracle should conform_to(@protocol(XMASSelectedProtocolOracle));
    });
});

SPEC_END
