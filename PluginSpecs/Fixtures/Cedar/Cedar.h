#import <Foundation/Foundation.h>

#define SPEC_BEGIN(name)             \
@interface name : CDRSpec            \
@end                                 \
@implementation name                 \

#define SPEC_END                     \
}                                    \
@end

extern "C" {
    typedef void (^CDRSpecBlock)(void);

    void beforeEach(CDRSpecBlock);
    void afterEach(CDRSpecBlock);

    void describe(NSString *, CDRSpecBlock);
    void (*context)(NSString *, CDRSpecBlock);

    void it(NSString *, CDRSpecBlock);

    void xdescribe(NSString *, CDRSpecBlock);
    extern void (*xcontext)(NSString *, CDRSpecBlock);
    void subjectAction(CDRSpecBlock);
    void xit(NSString *, CDRSpecBlock);

    void fdescribe(NSString *, CDRSpecBlock);
    extern CDRExampleGroup* (*fcontext)(NSString *, CDRSpecBlock);
    void fit(NSString *, CDRSpecBlock);
}