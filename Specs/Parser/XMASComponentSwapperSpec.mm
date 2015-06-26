#import <Cedar/Cedar.h>
#import "XMASComponentSwapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASComponentSwapperSpec)

describe(@"XMASComponentSwapper", ^{
    __block XMASComponentSwapper *subject;

    beforeEach(^{
        subject = [[XMASComponentSwapper alloc] init];
    });

    it(@"should camelcase names correctly", ^{
        XMASComponentPair *pair = [subject swapComponent:@"initWithServiceManager" withComponent:@"delegate"];
        pair.first should equal(@"initWithDelegate");
        pair.second should equal(@"serviceManager");
    });

    it(@"should camelcase names regardless of the order they are passed in", ^{
        XMASComponentPair *pair = [subject swapComponent:@"delegate" withComponent:@"initWithServiceManager"];
        pair.first should equal(@"serviceManager");
        pair.second should equal(@"initWithDelegate");
    });

    it(@"should camelcase names even when a component starts with 'and'", ^{
        XMASComponentPair *pair = [subject swapComponent:@"initWithServiceManager" withComponent:@"andDelegate"];
        pair.first should equal(@"initWithDelegate");
        pair.second should equal(@"andServiceManager");
    });

    it(@"should camelcase names even when a component starts with 'and' regardless of order", ^{
        XMASComponentPair *pair = [subject swapComponent:@"andDelegate" withComponent:@"initWithServiceManager"];
        pair.first should equal(@"andServiceManager");
        pair.second should equal(@"initWithDelegate");
    });

    it(@"should handle strangely named selector components", ^{
        XMASComponentPair *pair = [subject swapComponent:@"initWith" withComponent:@"and"];
        pair.first should equal(@"and");
        pair.second should equal(@"initWith");
    });
});

SPEC_END
