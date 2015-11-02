#import <Cedar/Cedar.h>
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
        protocolFaker stub_method(@selector(fakeForProtocol:)).and_return(@"this-that-fake");

        subject = [[XMASFakeProtocolPersister alloc] initWithProtocolFaker:protocolFaker
                                                               fileManager:fileManager];
    });

    NSString *pathToFixture = @"/tmp/pretend/this/is/real";
    ProtocolDeclaration *protocolDecl = nice_fake_for([ProtocolDeclaration class]);
    protocolDecl stub_method(@selector(name)).and_return(@"SpecialTester");

    subjectAction(^{
        [subject persistFakeForProtocol:protocolDecl nearSourceFile:pathToFixture];
    });

    describe(@"when the fakes directory does not yet exist", ^{
        beforeEach(^{
            fileManager stub_method(@selector(fileExistsAtPath:isDirectory:)).and_return(NO);
            fileManager stub_method(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:));
            fileManager stub_method(@selector(createFileAtPath:contents:attributes:));
        });

        NSString *expectedFakesDir = [pathToFixture.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"fakes"];
        it(@"should create the directory through its file manager", ^{
            fileManager should have_received(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:))
                .with(expectedFakesDir, YES, Arguments::anything, Arguments::anything);
        });

        it(@"should ask its protocol faker to create a fake for the given protocol", ^{
            protocolFaker should have_received(@selector(fakeForProtocol:)).with(protocolDecl);
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

    describe(@"when the fakes directory does exist", ^{
        beforeEach(^{
            fileManager stub_method(@selector(fileExistsAtPath:isDirectory:)).and_return(YES);
            fileManager stub_method(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:));
            fileManager stub_method(@selector(createFileAtPath:contents:attributes:));
        });

        it(@"should not create a directory", ^{
            fileManager should_not have_received(@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:));
        });
    });
});

SPEC_END
