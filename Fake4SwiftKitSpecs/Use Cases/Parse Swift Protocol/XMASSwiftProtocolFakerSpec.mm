#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>

#import "Fake4SwiftKitSpecs-Swift.h"
#import "Fake4SwiftKitModule.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASSwiftProtocolFakerSpec)

describe(@"XMASSwiftProtocolFaker", ^{
    __block XMASSwiftProtocolFaker *subject;
    __block ProtocolDeclaration *protocolDeclaration;

    beforeEach(^{
        NSArray *modules = @[[[Fake4SwiftKitModule alloc] init]];
        id<BSInjector, BSBinder> injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModules:modules];

        [injector bind:@"mustacheTemplateBundle" toInstance:[NSBundle mainBundle]];

        subject = [injector getInstance:[XMASSwiftProtocolFaker class]];
    });

    describe(@"given a fairly standard looking protocol that could be implemented by a class", ^{
        beforeEach(^{
            Accessor *myAttrGetter = [[Accessor alloc] initWithName:@"myAttribute" returnType:@"Int"];
            Accessor *myNameGetterSetter = [[Accessor alloc] initWithName:@"myName" returnType:@"String"];

            MethodDeclaration *doesNothing = [[MethodDeclaration alloc] initWithName:@"doesNothing"
                                                                         throwsError:NO
                                                                           arguments:@[]
                                                                    returnValueTypes:@[]];
            NSArray<MethodParameter *> *doesStuffArgs = @[
                                                          [[MethodParameter alloc] initWithName:@"stuff"
                                                                                           type:@"String"],
                                                          [[MethodParameter alloc] initWithName:@"otherStuff"
                                                                                           type:@"[String]"],
                                                          ];
            MethodDeclaration *doesStuff = [[MethodDeclaration alloc] initWithName:@"doesStuff"
                                                                       throwsError:NO
                                                                         arguments:doesStuffArgs
                                                                  returnValueTypes:@[@"[String]", @"Int"]];
            NSArray<MethodParameter *> *funkyArgs = @[[[MethodParameter alloc] initWithName:@"drummer"
                                                                                       type:@"String?"]];
            MethodDeclaration *soulOfAFunky = [[MethodDeclaration alloc] initWithName:@"soulOfAFunky"
                                                                          throwsError:YES
                                                                            arguments:funkyArgs
                                                                     returnValueTypes:@[@"String?"]];

            NSArray<MethodParameter *> *staticArgs = @[[[MethodParameter alloc] initWithName:@"isStatic"
                                                                                        type:@"String"],
                                                       [[MethodParameter alloc] initWithName:@"soStatic"
                                                                                        type:@"Bool"]];
            MethodDeclaration *staticMethod = [[MethodDeclaration alloc] initWithName:@"staticMethod"
                                                                          throwsError:NO
                                                                            arguments:staticArgs
                                                                     returnValueTypes:@[@"Array<String>"]];

            protocolDeclaration = [[ProtocolDeclaration alloc] initWithName:@"MySomewhatSpecialProtocol"
                                                             containingFile:@""
                                                                rangeInFile:NSMakeRange(0, 0)
                                                              usesTypealias:NO
                                                          includedProtocols:@[]
                                                            instanceMethods:@[doesNothing, doesStuff, soulOfAFunky]
                                                              staticMethods:@[staticMethod]
                                                            mutatingMethods:@[]
                                                               initializers:@[]
                                                                    getters:@[myAttrGetter]
                                                                    setters:@[myNameGetterSetter]
                                                              staticGetters:@[]
                                                              staticSetters:@[]
                                                           subscriptGetters:@[]
                                                           subscriptSetters:@[]];
        });

        NSString *expectedFakePath = [[NSBundle mainBundle] pathForResource:@"FakeForMySomewhatSpecialProtocol" ofType:@"swift"];

        it(@"should create a reasonably useful fake for the selected protocol", ^{
            NSString *expectedContents = [NSString stringWithContentsOfFile:expectedFakePath encoding:NSUTF8StringEncoding error:nil];

            NSError *error;
            NSString *testDouble = [subject fakeForProtocol:protocolDeclaration error:&error];
            error should be_nil;
            testDouble should equal(expectedContents);
        });
    });

    describe(@"given a protocol that can only be implemented by a struct", ^{
        beforeEach(^{
            NSArray<MethodParameter *> *arguments = @[
                                                      [[MethodParameter alloc] initWithName:@"arg"
                                                                                       type:@"String"],
                                                      [[MethodParameter alloc] initWithName:@"arg2"
                                                                                       type:@"String"],
                                                      ];
            MethodDeclaration *mutatingMethod = [[MethodDeclaration alloc] initWithName:@"mutableMethod"
                                                                            throwsError:NO
                                                                              arguments:arguments
                                                                       returnValueTypes:@[@"String"]];

            protocolDeclaration = [[ProtocolDeclaration alloc] initWithName:@"MyMutatingProtocol"
                                                             containingFile:@""
                                                                rangeInFile:NSMakeRange(0, 0)
                                                              usesTypealias:NO
                                                          includedProtocols:@[]
                                                            instanceMethods:@[]
                                                              staticMethods:@[]
                                                            mutatingMethods:@[mutatingMethod]
                                                               initializers:@[]
                                                                    getters:@[]
                                                                    setters:@[]
                                                              staticGetters:@[]
                                                              staticSetters:@[]
                                                           subscriptGetters:@[]
                                                           subscriptSetters:@[]];
        });

        NSString *expectedFakePath = [[NSBundle mainBundle] pathForResource:@"FakeForMyMutatingProtocol" ofType:@"swift"];

        it(@"should create a struct that implements the protocol", ^{
            NSString *expectedContents = [NSString stringWithContentsOfFile:expectedFakePath encoding:NSUTF8StringEncoding error:nil];

            NSError *error;
            NSString *testDouble = [subject fakeForProtocol:protocolDeclaration error:&error];

            error should be_nil;
            testDouble should equal(expectedContents);
        });
    });
});

SPEC_END
