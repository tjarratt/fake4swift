#import <Cedar/Cedar.h>
#import "XMASTokenizer.h"
#import "TempFileHelper.h"
#import "XMASXcodeTargetSearchPathResolver.h"
#import "XMASXcode.h"
#import "FakeXcodeFileReference.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASTokenizerSpec)

describe(@"XMASTokenizer", ^{
    __block XMASTokenizer *subject;
    __block XMASXcodeTargetSearchPathResolver *targetSearchPathResolver;

    NSString *objcFixturePath = [[NSBundle mainBundle] pathForResource:@"MethodDeclaration" ofType:@"m"];
    NSString *objcPlusPlusFixturePath = [[NSBundle mainBundle] pathForResource:@"CedarSpecFixture" ofType:@"mm"];
    NSString *fakeHeaderPath = [TempFileHelper temporaryFilePathForFixture:@"Cedar"
                                                                    ofType:@"h"
                                               withContainingDirectoryPath:@"Cedar.framework/Headers"];

    NSArray *args = @[[@"-F" stringByAppendingString:fakeHeaderPath]];

    beforeEach(^{
        spy_on([XMASXcode class]);
    });

    afterEach(^{
        stop_spying_on([XMASXcode class]);
    });

    beforeEach(^{
        id theCorrectTarget = nice_fake_for(@protocol(XCP(Xcode3Target)));
        id someOtherTarget = nice_fake_for(@protocol(XCP(Xcode3Target)));

        FakeXcodeFileReference *objcFixtureFileRef = [[FakeXcodeFileReference alloc] initWithFilePath:objcFixturePath];
        FakeXcodeFileReference *objcPlusPlusFixtureFileRef = [[FakeXcodeFileReference alloc] initWithFilePath:objcPlusPlusFixturePath];

        NSArray *buildFileReferences = @[objcPlusPlusFixtureFileRef, objcFixtureFileRef];
        theCorrectTarget stub_method(@selector(allBuildFileReferences)).and_return(buildFileReferences);

        [XMASXcode class] stub_method(@selector(targetsInCurrentWorkspace)).and_return(@[someOtherTarget, theCorrectTarget]);

        targetSearchPathResolver = nice_fake_for([XMASXcodeTargetSearchPathResolver class]);
        targetSearchPathResolver stub_method(@selector(effectiveHeaderSearchPathsForTarget:))
            .with(theCorrectTarget)
            .and_return(args);

        subject = [[XMASTokenizer alloc] initWithTargetSearchPathResolver:targetSearchPathResolver];
    });

    context(@"for Obj-C files without macros", ^{
        it(@"should return tokens for file of the given path", ^{
            NSArray *tokens = [subject tokensForFilePath:objcFixturePath];
            [tokens valueForKeyPath:@"cursor.kindSpelling"] should contain(@"ObjCMessageExpr");
        });
    });

    context(@"for Obj-C++ files with macros", ^{
        fit(@"should return tokens for file of the given path", ^{
            NSArray *tokens = [subject tokensForFilePath:objcPlusPlusFixturePath];
            [tokens valueForKeyPath:@"cursor.kindSpelling"] should contain(@"ObjCImplementationDecl");
        });
    });
});

SPEC_END
