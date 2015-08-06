#import <Cedar/Cedar.h>
#import "XMASXcodeTargetSearchPathResolver.h"
#import "XMASSearchPathExpander.h"
#import "XcodeInterfaces.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASXcodeTargetSearchPathResolverSpec)

describe(@"XMASXcodeTargetSearchPathResolver", ^{
    __block XMASXcodeTargetSearchPathResolver *subject;
    __block XMASSearchPathExpander *searchPathExpander;

    beforeEach(^{
        searchPathExpander = [[XMASSearchPathExpander alloc] init];
        subject = [[XMASXcodeTargetSearchPathResolver alloc] initWithPathExpander:searchPathExpander];
    });

    describe(@"-effectiveHeaderSearchPathsForTarget:", ^{
        __block NSArray *paths;
        __block XC(XCStringList) relativeSearchPaths;
        __block XC(XCStringList) absoluteSearchPaths;

        beforeEach(^{
            relativeSearchPaths = nice_fake_for(@protocol(XCP(XCStringList)));
            relativeSearchPaths stub_method(@selector(arrayRepresentation))
                .and_return(@[@"path/some/relative/path"]);
            absoluteSearchPaths = nice_fake_for(@protocol(XCP(XCStringList)));
            absoluteSearchPaths stub_method(@selector(arrayRepresentation))
                .and_return(@[@"/another/root/path/some/relative/path/something"]);


            NSDictionary *fakeTarget = @{
                                         @"targetBuildContext": @{
                                                 @"effectiveSearchPaths": @{
                                                         @"/the/root/path" : relativeSearchPaths,
                                                         @"/another/root/path" : absoluteSearchPaths,
                                                         }
                                                 }
                                         };
            paths = [subject effectiveHeaderSearchPathsForTarget:(id)fakeTarget];
        });

        it(@"should find the search paths in the target, expanding relative paths", ^{
            paths should contain(@"/the/root/path/some/relative/path");
            paths should contain(@"/another/root/path/some/relative/path/something");
        });
    });
});

SPEC_END
