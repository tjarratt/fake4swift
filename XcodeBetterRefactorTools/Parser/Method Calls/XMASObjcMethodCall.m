#import "XMASObjcMethodCall.h"

@interface XMASObjcMethodCall ()
@property (nonatomic) NSArray *selectorComponents;
@property (nonatomic) NSInteger columnNumber;
@property (nonatomic) NSInteger lineNumber;
@property (nonatomic) NSArray *arguments;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSRange range;
@end

@implementation XMASObjcMethodCall

- (instancetype)initWithSelectorComponents:(NSArray *)selectorComponents
                              columnNumber:(NSInteger)columnNumber
                                lineNumber:(NSInteger)lineNumber
                                 arguments:(NSArray *)arguments
                                  filePath:(NSString *)filePath
                                     range:(NSRange)range {
    if (self = [super init]) {
        self.selectorComponents = selectorComponents;
        self.columnNumber = columnNumber;
        self.lineNumber = lineNumber;
        self.arguments = arguments;
        self.filePath = filePath;
        self.range = range;
    }

    return self;
}

- (NSString *)selectorString {
    return _arguments.count > 0 ? [[_selectorComponents componentsJoinedByString:@":"] stringByAppendingString:@":"] : _selectorComponents.firstObject;
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
