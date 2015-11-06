#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "Specs-Swift.h"
#import "RefactorToolsModule.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASSelectedSwiftProtocolProxySpec)

describe(@"XMASSelectedSwiftProtocolProxy", ^{
    __block XMASSelectedSwiftProtocolProxy *subject;
    __block XMASXcodeRepository *fakeXcodeRepository;

    beforeEach(^{
        NSArray *modules = @[[[RefactorToolsModule alloc] init]];
        id<BSInjector, BSBinder> injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModules:modules];

        fakeXcodeRepository = nice_fake_for([XMASXcodeRepository class]);
        [injector bind:[XMASXcodeRepository class] toInstance:fakeXcodeRepository];

        subject = [injector getInstance:@protocol(XMASSelectedTextProxy)];
    });

    NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"ProtocolEdgeCases"
                                                            ofType:@"swift"];

    context(@"when a swift protocol is selected", ^{
        __block ProtocolDeclaration *protocolDeclaration;
        beforeEach(^{
            fakeXcodeRepository stub_method(@selector(cursorSelectionRange)).and_return(NSMakeRange(11, 0));
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

        it(@"should parse the instance methods", ^{
            protocolDeclaration.instanceMethods.count should equal(5);

            NSArray<NSString *> *expectedMethodNames = @[
                                                        @"voidMethod",
                                                        @"randomDouble",
                                                        @"randomDoubleWithSeed",
                                                        @"randomDoubleWithSeeds",
                                                        @"returnsMultipleValues"];
            [protocolDeclaration.instanceMethods valueForKey:@"name"] should equal(expectedMethodNames);

            NSArray<NSString *> *expectedArgumentNames = @[
                                                           @[],
                                                           @[],
                                                           @[@"seed"],
                                                           @[@"seed", @"secondSeed"],
                                                           @[],
                                                           ];
            [[protocolDeclaration.instanceMethods valueForKey:@"arguments"] valueForKey:@"name"] should equal(expectedArgumentNames);

            NSArray<NSString *> *expectedArgumentTypes = @[
                                                         @[],
                                                         @[],
                                                         @[@"Int"],
                                                         @[@"Int", @"Int"],
                                                         @[],
                                                         ];
            [[protocolDeclaration.instanceMethods valueForKey:@"arguments"] valueForKey:@"type"] should equal(expectedArgumentTypes);

            NSArray<NSString *> *expectedReturnTypes = @[
                                                        @[],
                                                        @[@"Double"],
                                                        @[@"Double"],
                                                        @[@"Double"],
                                                        @[@"Double", @"Double"],
                                                        ];
            [protocolDeclaration.instanceMethods valueForKey:@"returnValueTypes"] should equal(expectedReturnTypes);
        });
    });

    context(@"when no protocol is selected", ^{
        it(@"should return nil", ^{
            [subject selectedProtocolInFile:fixturePath] should be_nil;
        });
    });
});

SPEC_END
