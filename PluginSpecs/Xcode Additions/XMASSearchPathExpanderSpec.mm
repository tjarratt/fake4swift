#import <Cedar/Cedar.h>
#import "XMASSearchPathExpander.h"
#import "XcodeInterfaces.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASSearchPathExpanderSpec)

describe(@"XMASSearchPathExpander", ^{
    __block XMASSearchPathExpander *subject;

    beforeEach(^{
        subject = [[XMASSearchPathExpander alloc] init];
    });

    describe(@"-expandSearchPaths:forRootPath:", ^{
        __block NSArray *results;

        __block XC(XCStringList) searchPaths;
        __block NSString *rootPath;

        context(@"when the search paths are absolute", ^{
            beforeEach(^{
                searchPaths = nice_fake_for(@protocol(XCP(XCStringList)));
                searchPaths stub_method(@selector(arrayRepresentation))
                    .and_return(@[@"/some/absolute/path/to/a/directory"]);

                results = [subject expandSearchPaths:searchPaths forRootPath:rootPath];
            });

            it(@"should contain the absolute paths from the search paths", ^{
                results.count should equal(1);
                results should contain(@"/some/absolute/path/to/a/directory");
            });
        });

        context(@"when the search paths are relative", ^{
            beforeEach(^{
                searchPaths = nice_fake_for(@protocol(XCP(XCStringList)));
                searchPaths stub_method(@selector(arrayRepresentation))
                    .and_return(@[@"relative/path"]);

                rootPath = @"/path/that/is/relative/**";
                results = [subject expandSearchPaths:searchPaths forRootPath:rootPath];

            });

            it(@"should contain the absolute paths for the given relative search paths", ^{
                results.count should equal(1);
                results should contain(@"/path/that/is/relative/path");
            });
        });

    });
});

SPEC_END
