#import <Cedar/Cedar.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit-Swift.h>

#import "XMASFakeProtocolPersister.h"
#import "SwiftCompatibilityHeader.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASFakeProtocolPersisterSpec)

describe(@"XMASFakeProtocolPersister", ^{
    __block XMASFakeProtocolPersister *subject;

    __block NSFileManager <CedarDouble>*fileManager;
    __block XMASSwiftProtocolFaker *protocolFaker;

    beforeEach(^{
        fileManager = fake_for([NSFileManager class]);
        protocolFaker = nice_fake_for([XMASSwiftProtocolFaker class]);
        protocolFaker stub_method(@selector(fakeForProtocol:error:)).and_return(@"this-that-fake");

        subject = [[XMASFakeProtocolPersister alloc] initWithProtocolFaker:protocolFaker
                                                               fileManager:fileManager];
    });

    NSString *pathToFixture = @"/tmp/pretend/this/is/real";
    ProtocolDeclaration *protocolDecl = nice_fake_for([ProtocolDeclaration class]);
    protocolDecl stub_method(@selector(name)).and_return(@"SpecialTester");

    describe(@"when the fakes directory does not yet exist", ^{
        NSString *expectedFakesDir = [pathToFixture.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"fakes"];

        beforeEach(^{
            fileManager stub_method(@selector(fileExistsAtPath:isDirectory:)).and_return(NO);
            fileManager stub_method(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:));
            fileManager stub_method(@selector(createFileAtPath:contents:attributes:));
        });

        context(@"when the fake can be created", ^{
            beforeEach(^{
                [subject persistFakeForProtocol:protocolDecl nearSourceFile:pathToFixture];
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

                NSArray *messages = [fileManager sent_messages_with_selector:@selector(createFileAtPath:contents:attributes:)];
                NSInvocation *invocation = messages.firstObject;

                __unsafe_unretained NSData *receivedData;
                [invocation getArgument:&receivedData atIndex:3];
                NSData *expectedData = [@"this-that-fake" dataUsingEncoding:NSUTF8StringEncoding];
                [expectedData isEqualToData:receivedData] should be_truthy;
            });
        });

        context(@"when creating the fake fails", ^{
            beforeEach(^{
                protocolFaker stub_method(@selector(fakeForProtocol:error:)).again().and_do_block(^NSString *(id something, NSError **error) {
                    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: @"could not burgle the burglars"};
                    *error = [NSError errorWithDomain:@"my-domain" code:5 userInfo:userInfo];
                    return nil;
                });
            });

            it(@"should raise an exception", ^{
                expect(^{
                    [subject persistFakeForProtocol:protocolDecl nearSourceFile:pathToFixture];
                }).to(raise_exception.with_reason(@"could not burgle the burglars"));
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
            fileManager stub_method(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:));
            fileManager stub_method(@selector(createFileAtPath:contents:attributes:));

            [subject persistFakeForProtocol:protocolDecl nearSourceFile:pathToFixture];
        });

        it(@"should not create a directory", ^{
            fileManager should_not have_received(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:));
        });
    });
});

SPEC_END
