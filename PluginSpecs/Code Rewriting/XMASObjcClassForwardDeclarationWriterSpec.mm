#import <Cedar/Cedar.h>
#import "XMASObjcClassForwardDeclarationWriter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcClassForwardDeclarationSpec)

describe(@"XMASObjcClassForwardDeclarationWriter", ^{
    __block XMASObjcClassForwardDeclarationWriter *subject;

    beforeEach(^{
        subject = [[XMASObjcClassForwardDeclarationWriter alloc] init];
    });

    it(@"should write a forward description for a class", ^{
        [subject forwardDeclarationForClassNamed:@"Zomg"] should equal(@"@class Zomg;\n");
    });
});

SPEC_END
