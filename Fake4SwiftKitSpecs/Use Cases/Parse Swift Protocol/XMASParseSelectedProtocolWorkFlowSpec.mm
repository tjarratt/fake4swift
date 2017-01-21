#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>

#import "Fake4SwiftKitSpecs-Swift.h"
#import "Fake4SwiftKitModule.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASParseSelectedProtocolWorkFlowSpec)

describe(@"XMASParseSelectedProtocolWorkFlow", ^{
    __block XMASParseSelectedProtocolWorkFlow *subject;
    __block id<XMASSelectedProtocolOracle> fakeSelectedProtocolOracle;

    beforeEach(^{
        NSArray *modules = @[[[Fake4SwiftKitModule alloc] init]];
        id<BSInjector, BSBinder> injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModules:modules];

        fakeSelectedProtocolOracle = nice_fake_for(@protocol(XMASSelectedProtocolOracle));
        [injector bind:@protocol(XMASSelectedProtocolOracle) toInstance:fakeSelectedProtocolOracle];

        subject = [injector getInstance:[XMASParseSelectedProtocolWorkFlow class]];
    });

    NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"ProtocolEdgeCases"
                                                            ofType:@"swift"];

    context(@"when a swift protocol is selected", ^{
        __block ProtocolDeclaration *protocolDeclaration;
        beforeEach(^{
            fakeSelectedProtocolOracle stub_method(@selector(isProtocolSelected:))
                .and_return(YES);

            NSError *error = nil;
            protocolDeclaration = [subject selectedProtocolInFile:fixturePath error:&error];
            error should be_nil;
        });

        it(@"should parse the name of the selected protocol", ^{
            protocolDeclaration.name should equal(@"MySpecialProtocol");
        });

        it(@"should parse instance getters and setters", ^{
            [protocolDeclaration.getters.firstObject valueForKey:@"name"] should equal(@"numberOfWheels");
            [protocolDeclaration.getters.firstObject valueForKey:@"returnType"] should equal(@"Int");

            [protocolDeclaration.setters.firstObject valueForKey:@"name"] should equal(@"numberOfSomething");
            [protocolDeclaration.setters.firstObject valueForKey:@"returnType"] should equal(@"Int");
        });

        it(@"should parse static getters and setters", ^{
            [protocolDeclaration.staticGetters.firstObject valueForKey:@"name"] should equal(@"classGetter");
            [protocolDeclaration.staticGetters.firstObject valueForKey:@"returnType"] should equal(@"Int");

            [protocolDeclaration.staticSetters.firstObject valueForKey:@"name"] should equal(@"classAccessor");
            [protocolDeclaration.staticSetters.firstObject valueForKey:@"returnType"] should equal(@"Int");
        });

        it(@"should parse instance methods", ^{
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

        it(@"should parse static methods", ^{
            protocolDeclaration.staticMethods.count should equal(1);

            MethodDeclaration *expectedMethod = [[MethodDeclaration alloc] initWithName:@"isStatic"
                                                                            throwsError:NO
                                                                              arguments:@[]
                                                                       returnValueTypes:@[]];
            protocolDeclaration.staticMethods.firstObject should equal(expectedMethod);
        });

        it(@"should indicate that the protocol does not use typealias", ^{
            protocolDeclaration.usesTypealias should be_falsy;
        });
    });

    context(@"when a swift protocol which includes other protocols is selected", ^{
        __block ProtocolDeclaration *protocolDeclaration;
        beforeEach(^{
            fakeSelectedProtocolOracle stub_method(@selector(isProtocolSelected:))
                .and_do_block(^BOOL(ProtocolDeclaration *protocolDecl) {
                    return [protocolDecl.name isEqualToString:@"IncludesOtherProtocol"];
                });

            NSError *error = nil;
            protocolDeclaration = [subject selectedProtocolInFile:fixturePath error:&error];
            error should be_nil;
        });

        it(@"should parse the name of the selected protocol", ^{
            protocolDeclaration.name should equal(@"IncludesOtherProtocol");
        });

        it(@"should include the names of the other protocols", ^{
            protocolDeclaration.includedProtocols should equal(@[@"MyOptionalProtocol", @"NSObjectProtocol"]);
        });

        it(@"should indicate that the protocol does not use typealias", ^{
            protocolDeclaration.usesTypealias should be_falsy;
        });
    });

    context(@"when a swift protocol with mutating methods is selected", ^{
        __block ProtocolDeclaration *protocolDeclaration;
        beforeEach(^{
            fakeSelectedProtocolOracle stub_method(@selector(isProtocolSelected:))
            .and_do_block(^BOOL(ProtocolDeclaration *protocolDecl) {
                return [protocolDecl.name isEqualToString:@"ImplementableByStructsOnly"];
            });

            NSError *error = nil;
            protocolDeclaration = [subject selectedProtocolInFile:fixturePath error:&error];
            error should be_nil;
        });

        it(@"should parse the name of the selected protocol", ^{
            protocolDeclaration.name should equal(@"ImplementableByStructsOnly");
        });

        it(@"should parse mutable methods", ^{
            MethodDeclaration *expectedMethod = [[MethodDeclaration alloc] initWithName:@"mutates"
                                                                            throwsError:NO
                                                                              arguments:@[]
                                                                       returnValueTypes:@[]];
            protocolDeclaration.mutatingMethods should equal(@[expectedMethod]);
        });

        it(@"should indicate that the protocol does not use typealias", ^{
            protocolDeclaration.usesTypealias should be_falsy;
        });
    });

    context(@"when a swift protocol with methods that throw is selected", ^{
        __block ProtocolDeclaration *protocolDeclaration;
        beforeEach(^{
            fakeSelectedProtocolOracle stub_method(@selector(isProtocolSelected:))
                .and_do_block(^BOOL(ProtocolDeclaration *protocolDecl) {
                    return [protocolDecl.name isEqualToString:@"ThingsThatGoBoom"];
                });

            NSError *error = nil;
            protocolDeclaration = [subject selectedProtocolInFile:fixturePath error:&error];
            error should be_nil;
        });

        it(@"should select the correct protocol", ^{
            protocolDeclaration.name should equal(@"ThingsThatGoBoom");
        });

        it(@"should have methods that throws errors", ^{
            protocolDeclaration.instanceMethods should contain([[MethodDeclaration alloc] initWithName:@"thisVoidMethodThrows"
                                                                                           throwsError:YES
                                                                                             arguments:@[]
                                                                                      returnValueTypes:@[]]);

            protocolDeclaration.instanceMethods should contain([[MethodDeclaration alloc] initWithName:@"thisMethodThrowsToo"
                                                                                           throwsError:YES
                                                                                             arguments:@[]
                                                                                      returnValueTypes:@[@"String"]]);

        });

        it(@"should indicate that the protocol does not use typealias", ^{
            protocolDeclaration.usesTypealias should be_falsy;
        });
    });

    context(@"when the swift protocol uses typealias", ^{
        __block ProtocolDeclaration *protocolDeclaration;
        beforeEach(^{
            fakeSelectedProtocolOracle stub_method(@selector(isProtocolSelected:))
                .and_do_block(^BOOL(ProtocolDeclaration *protocolDecl) {
                    return [protocolDecl.name isEqualToString:@"GenericProtocolWithTypeAlias"];
                });

            NSError *error = nil;
            protocolDeclaration = [subject selectedProtocolInFile:fixturePath error:&error];
            error should be_nil;
        });

        it(@"should parse the correct protocol", ^{
            protocolDeclaration.name should equal(@"GenericProtocolWithTypeAlias");
        });

        it(@"should indicate that the protocol uses typealias", ^{
            protocolDeclaration.usesTypealias should be_truthy;
        });
    });

    context(@"when a protocol with no methods is selected", ^{
        __block ProtocolDeclaration *protocolDeclaration;
        NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"EmptyProtocol"
                                                                ofType:@"swift"];
        beforeEach(^{
            fixturePath should_not be_nil;

            fakeSelectedProtocolOracle stub_method(@selector(isProtocolSelected:))
                .and_return(YES);

            NSError *error = nil;
            protocolDeclaration = [subject selectedProtocolInFile:fixturePath error:&error];
            error should be_nil;
        });

        it(@"should parse it as an empty protocol declaration", ^{
            protocolDeclaration should equal([[ProtocolDeclaration alloc] initWithName:@"Empty"
                                                                        containingFile:fixturePath
                                                                           rangeInFile:NSMakeRange(0, 19)
                                                                         usesTypealias:NO
                                                                     includedProtocols:@[]
                                                                       instanceMethods:@[]
                                                                         staticMethods:@[]
                                                                       mutatingMethods:@[]
                                                                          initializers:@[]
                                                                               getters:@[]
                                                                               setters:@[]
                                                                         staticGetters:@[]
                                                                         staticSetters:@[]
                                                                      subscriptGetters:@[]
                                                                      subscriptSetters:@[]]);
        });
    });

    context(@"when no protocol is selected", ^{
        it(@"should throw an error", ^{
            fakeSelectedProtocolOracle stub_method(@selector(isProtocolSelected:))
                .and_return(NO);

            NSError *error = nil;
            [subject selectedProtocolInFile:fixturePath error:&error];
            error should_not be_nil;
            error.localizedFailureReason should equal(@"No protocol was selected");
        });
    });
});

SPEC_END
