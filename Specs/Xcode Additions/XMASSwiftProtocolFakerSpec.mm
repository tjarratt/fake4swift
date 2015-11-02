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

    beforeEach(^{
        NSArray *modules = @[[[RefactorToolsModule alloc] init]];
        id<BSInjector, BSBinder> injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModules:modules];

        XMASXcodeRepository *fakeXcodeRepository = nice_fake_for([XMASXcodeRepository class]);
        [injector bind:[XMASXcodeRepository class] toInstance:fakeXcodeRepository];

        subject = [injector getInstance:[XMASSwiftProtocolFaker class]];

        id<XMASSelectedTextProxy> selectedTextProxy = [injector getInstance:@protocol(XMASSelectedTextProxy)];
        NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"MySomewhatSpecialProtocol"
                                                                ofType:@"swift"];

        fakeXcodeRepository stub_method(@selector(cursorSelectionRange)).and_return(NSMakeRange(11, 0));
        protocolDeclaration = [selectedTextProxy selectedProtocolInFile:fixturePath];
    });

    NSString *expectedFakePath = [[NSBundle mainBundle] pathForResource:@"FakeForMySpecialProtocol" ofType:@"swift"];

    it(@"should create a reasonably useful fake for the selected protocol", ^{
        NSString *expectedContents = [NSString stringWithContentsOfFile:expectedFakePath encoding:NSUTF8StringEncoding error:nil];

        NSString *whatWeGot = [subject fakeForProtocol:protocolDeclaration];
        if (![expectedContents isEqualToString:whatWeGot]) {
            NSRange range = [whatWeGot rangeOfString:expectedContents];
            NSLog(@"%@", [expectedContents commonPrefixWithString:whatWeGot options:0]);
            NSLog(@"%lu-%lu", range.location, range.length);
        }

        [subject fakeForProtocol:protocolDeclaration] should equal(expectedContents);
    });
});

SPEC_END
