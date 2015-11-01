#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "Specs-Swift.h"
#import "RefactorToolsModule.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASSelectedSwiftProtocolProxySpec)

fdescribe(@"XMASSelectedSwiftProtocolProxy", ^{
    __block XMASSelectedSwiftProtocolProxy *subject;
    __block XMASXcodeRepository *fakeXcodeRepository;

    beforeEach(^{
        NSArray *modules = @[[[RefactorToolsModule alloc] init]];
        id<BSInjector, BSBinder> injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModules:modules];

        fakeXcodeRepository = nice_fake_for([XMASXcodeRepository class]);
        [injector bind:[XMASXcodeRepository class] toInstance:fakeXcodeRepository];

        subject = [injector getInstance:@protocol(XMASSelectedTextProxy)];
    });

    context(@"when a swift protocol is selected", ^{
        __block ProtocolDeclaration *protocolDeclaration;
        beforeEach(^{
            fakeXcodeRepository stub_method(@selector(cursorSelectionRange)).and_return(NSMakeRange(11, 0));

            NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"ProtocolEdgeCases"
                                                                    ofType:@"swift"];

            protocolDeclaration = [subject selectedProtocolInFile:fixturePath];
        });

        it(@"should parse the name of the selected protocol", ^{
            protocolDeclaration.name should equal(@"MySpecialProtocol");
        });

        it(@"should parse the instance getters and setters", ^{
            [protocolDeclaration.getters.firstObject valueForKey:@"name"] should equal(@"numberOfWheels");
            [protocolDeclaration.getters.firstObject valueForKey:@"returnType"] should equal(@"Int");

            [protocolDeclaration.setters.firstObject valueForKey:@"name"] should equal(@"numberOfSomething");
            [protocolDeclaration.setters.firstObject valueForKey:@"returnType"] should equal(@"Int");
        });

        it(@"should parse the static getters and setters", ^{
            [protocolDeclaration.staticGetters.firstObject valueForKey:@"name"] should equal(@"classGetter");
            [protocolDeclaration.staticGetters.firstObject valueForKey:@"returnType"] should equal(@"Int");

            [protocolDeclaration.staticSetters.firstObject valueForKey:@"name"] should equal(@"classAccessor");
            [protocolDeclaration.staticSetters.firstObject valueForKey:@"returnType"] should equal(@"Int");
        });
    });
});

SPEC_END
