#import <Cedar/Cedar.h>

#import "Fake4SwiftKitSpecs-Swift.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASFakeProtocolPersisterSpec)

describe(@"XMASFakeProtocolPersister", ^{
    __block XMASFakeProtocolPersister *subject;

    __block id<XMASSwiftProtocolFaking> protocolFaker;
    __block id<XMASFileManager, CedarDouble> fileManager;

    beforeEach(^{
        fileManager = nice_fake_for(@protocol(XMASFileManager));
        protocolFaker = nice_fake_for(@protocol(XMASSwiftProtocolFaking));
        protocolFaker stub_method(@selector(fakeForProtocol:error:))
            .and_return(@"this-that-fake");

        subject = [[XMASFakeProtocolPersister alloc] initWithProtocolFaker:protocolFaker
                                                               fileManager:fileManager];
    });

    NSString *pathToFixture = @"/tmp/pretend/this/is/real/SpecialTester.swift";
    ProtocolDeclaration *protocolDecl = [[ProtocolDeclaration alloc] initWithName:@"SpecialTester"
                                                                   containingFile:@""
                                                                      rangeInFile:NSMakeRange(0, 0)
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
                                                                 subscriptSetters:@[]];

    describe(@"when the fakes directory does not yet exist", ^{
        NSString *expectedFakesDir = [pathToFixture.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"fakes"];

        beforeEach(^{
            fileManager stub_method(@selector(fileExistsAtPath:isDirectory:)).and_return(NO);
            fileManager stub_method(@selector(createDirectoryAtPath:
                                              withIntermediateDirectories:
                                              attributes:error:)).and_return(YES);
            fileManager stub_method(@selector(createFileAtPath:contents:attributes:));
        });

        context(@"when the fake can be created", ^{
            __block NSError *error;
            __block FakeProtocolPersistResults *result;

            beforeEach(^{
                error = nil;
                result = [subject persistFakeForProtocol:protocolDecl
                                          nearSourceFile:pathToFixture
                                                   error:&error];
            });

            it(@"should have completed successfully", ^{
                error should be_nil;
            });

            it(@"should return the path to the fake and its containing dir", ^{
                result.pathToFake should equal(@"/tmp/pretend/this/is/real/fakes/FakeSpecialTester.swift");
                result.directoryName should equal(@"fakes");
            });

            it(@"should create the directory through its file manager", ^{
                fileManager should have_received(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:))
                    .with(expectedFakesDir, YES, Arguments::anything, Arguments::anything);
            });

            it(@"should ask its protocol faker to create a fake for the given protocol", ^{
                protocolFaker should have_received(@selector(fakeForProtocol:error:))
                    .with(protocolDecl, Arguments::anything);
            });

            it(@"should write the fake out through its file manager", ^{
                NSString *expectedPath = [expectedFakesDir stringByAppendingPathComponent:@"FakeSpecialTester.swift"];
                fileManager should have_received(@selector(createFileAtPath:contents:attributes:))
                    .with(expectedPath, Arguments::anything, Arguments::anything);

                NSArray *messages = [fileManager sent_messages_with_selector:@selector(createFileAtPath:
                                                                                       contents:
                                                                                       attributes:)];
                NSInvocation *invocation = messages.firstObject;

                __unsafe_unretained NSData *receivedData;
                [invocation getArgument:&receivedData atIndex:3];
                NSData *expectedData = [@"this-that-fake" dataUsingEncoding:NSUTF8StringEncoding];
                [expectedData isEqualToData:receivedData] should be_truthy;
            });
        });

        context(@"when creating the fake fails", ^{
            beforeEach(^{
                protocolFaker stub_method(@selector(fakeForProtocol:error:))
                    .again()
                    .and_do_block(^NSString *(id something, NSError **error) {
                        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: @"could not burgle the burglars"};
                        *error = [NSError errorWithDomain:@"my-domain" code:5 userInfo:userInfo];
                        return nil;
                    });
            });

            it(@"should return an error", ^{
                NSError *error = nil;
                [subject persistFakeForProtocol:protocolDecl nearSourceFile:pathToFixture error:&error];

                error should_not be_nil;
                error.localizedFailureReason should equal(@"could not burgle the burglars");
            });

            it(@"should not create a directory", ^{
                fileManager should_not have_received(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:));
            });

            it(@"should not write to a file", ^{
                fileManager should_not have_received(@selector(createFileAtPath:contents:attributes:));
            });
        });
    });

    describe(@"when the fakes directory does exist", ^{
        beforeEach(^{
            fileManager stub_method(@selector(fileExistsAtPath:isDirectory:)).and_return(YES);
            fileManager stub_method(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:))
                .and_return(YES);
            fileManager stub_method(@selector(createFileAtPath:contents:attributes:));

            [subject persistFakeForProtocol:protocolDecl nearSourceFile:pathToFixture error:nil];
        });

        it(@"should not create a directory", ^{
            fileManager should_not have_received(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:));
        });
    });
});

SPEC_END
