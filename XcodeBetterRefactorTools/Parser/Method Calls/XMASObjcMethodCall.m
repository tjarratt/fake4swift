#import "XMASObjcMethodCall.h"

@interface XMASObjcMethodCall ()
@property (nonatomic) NSArray *selectorComponents;
@property (nonatomic) NSArray *arguments;
@property (nonatomic) NSRange range;
@end

@implementation XMASObjcMethodCall

- (instancetype)initWithSelectorComponents:(NSArray *)selectorComponents
                                 arguments:(NSArray *)arguments
                                     range:(NSRange)range {
    if (self = [super init]) {
        self.selectorComponents = selectorComponents;
        self.arguments = arguments;
        self.range = range;
    }

    return self;
}

- (NSString *)selectorString {
    return _selectorComponents.count > 1 ? [[_selectorComponents componentsJoinedByString:@":"] stringByAppendingString:@":"] : _selectorComponents.firstObject;
}

- (NSRange)range  {
    return _range;
}

- (NSArray *)selectorComponents {
    return _selectorComponents;
}

- (NSArray *)arguments {
    return _arguments;
}


@end
