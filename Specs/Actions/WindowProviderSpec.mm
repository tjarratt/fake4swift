#import <Cedar/Cedar.h>
#import "WindowProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WindowProviderSpec)

describe(@"WindowProvider", ^{
    __block WindowProvider *subject;

    beforeEach(^{
        subject = [[WindowProvider alloc] init];
    });

    it(@"should provide a window", ^{
        subject.provideInstance should be_instance_of([NSWindow class]);
    });

    it(@"should only provide a single instance", ^{
        subject.provideInstance should be_same_instance_as(subject.provideInstance);
    });
});

SPEC_END
