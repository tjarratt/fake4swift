#import "XMASObjcMethodCall.h"

@interface XMASObjcMethodCall ()
@property (nonatomic) NSArray *selectorComponents;
@property (nonatomic) NSArray *arguments;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSRange range;
@end

@implementation XMASObjcMethodCall

- (instancetype)initWithSelectorComponents:(NSArray *)selectorComponents
                                 arguments:(NSArray *)arguments
                                  filePath:(NSString *)filePath
                                     range:(NSRange)range {
    if (self = [super init]) {
        self.selectorComponents = selectorComponents;
        self.arguments = arguments;
        self.filePath = filePath;
        self.range = range;
    }

    return self;
}

- (NSString *)selectorString {
    return _selectorComponents.count > 1 ? [[_selectorComponents componentsJoinedByString:@":"] stringByAppendingString:@":"] : _selectorComponents.firstObject;
}

- (NSArray *)selectorComponents {
    return _selectorComponents;
}

- (NSArray *)arguments {
    return _arguments;
}

- (NSString *)filePath {
    return _filePath;
}

- (NSRange)range  {
    return _range;
}


@end
