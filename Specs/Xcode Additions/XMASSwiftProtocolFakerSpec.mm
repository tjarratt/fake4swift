#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "Specs-Swift.h"
#import "RefactorToolsModule.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASSwiftProtocolFakerSpec)

describe(@"XMASSwiftProtocolFaker", ^{
    __block XMASSwiftProtocolFaker *subject;
    __block ProtocolDeclaration *protocolDeclaration;
    __block XMASXcodeRepository *fakeXcodeRepository;
    __block id<XMASSelectedTextProxy> selectedTextProxy;

    beforeEach(^{
        NSArray *modules = @[[[RefactorToolsModule alloc] init]];
        id<BSInjector, BSBinder> injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModules:modules];

        fakeXcodeRepository = nice_fake_for([XMASXcodeRepository class]);
        [injector bind:[XMASXcodeRepository class] toInstance:fakeXcodeRepository];
        [injector bind:@"MainBundle" toInstance:[NSBundle mainBundle]];

        subject = [injector getInstance:[XMASSwiftProtocolFaker class]];

        selectedTextProxy = [injector getInstance:@protocol(XMASSelectedTextProxy)];
    });

    describe(@"given a protocol that can only be implemented by a class", ^{
        beforeEach(^{
            fakeXcodeRepository stub_method(@selector(cursorSelectionRange)).and_return(NSMakeRange(11, 0));

            NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"MySomewhatSpecialProtocol"
                                                                    ofType:@"swift"];
            protocolDeclaration = [selectedTextProxy selectedProtocolInFile:fixturePath];
        });

        NSString *expectedFakePath = [[NSBundle mainBundle] pathForResource:@"FakeForMySpecialProtocol" ofType:@"swift"];

        it(@"should create a reasonably useful fake for the selected protocol", ^{
            NSString *expectedContents = [NSString stringWithContentsOfFile:expectedFakePath encoding:NSUTF8StringEncoding error:nil];

            NSError *error;
            [subject fakeForProtocol:protocolDeclaration error:&error] should equal(expectedContents);
            error should be_nil;
        });
    });

    describe(@"given a protocol that can only be implemented by a struct", ^{
        beforeEach(^{
            NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"MyMutatingProtocol"
                                                                    ofType:@"swift"];

            fakeXcodeRepository stub_method(@selector(cursorSelectionRange)).and_return(NSMakeRange(11, 0));
            protocolDeclaration = [selectedTextProxy selectedProtocolInFile:fixturePath];
        });

        NSString *expectedFakePath = [[NSBundle mainBundle] pathForResource:@"FakeForMyMutatingProtocol" ofType:@"swift"];

        it(@"should create a struct that implements the protocol", ^{
            NSString *expectedContents = [NSString stringWithContentsOfFile:expectedFakePath encoding:NSUTF8StringEncoding error:nil];

            NSError *error;
            [subject fakeForProtocol:protocolDeclaration error:&error] should equal(expectedContents);
            error should be_nil;
        });
    });
});

SPEC_END
