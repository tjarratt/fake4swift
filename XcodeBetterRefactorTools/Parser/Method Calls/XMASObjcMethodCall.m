#import "XMASObjcMethodCall.h"

@interface XMASObjcMethodCall ()
@property (nonatomic) NSArray *selectorComponents;
@property (nonatomic) NSUInteger columnNumber;
@property (nonatomic) NSUInteger lineNumber;
@property (nonatomic) NSArray *arguments;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSString *target;
@property (nonatomic) NSRange range;
@end

@implementation XMASObjcMethodCall

- (instancetype)initWithSelectorComponents:(NSArray *)selectorComponents
                              columnNumber:(NSUInteger)columnNumber
                                lineNumber:(NSUInteger)lineNumber
                                 arguments:(NSArray *)arguments
                                  filePath:(NSString *)filePath
                                    target:(NSString *)target
                                     range:(NSRange)range {
    if (self = [super init]) {
        self.selectorComponents = selectorComponents;
        self.columnNumber = columnNumber;
        self.lineNumber = lineNumber;
        self.arguments = arguments;
        self.filePath = filePath;
        self.target = target;
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

- (NSString *)target {
    return _target;
}

- (NSRange)range  {
    return _range;
}

#pragma mark - <NSObject>

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"XMASCallExpression: (SEL %@) (args %@) (target %@) (line %lu) (column %lu) (range %@)", self.selectorString, self.arguments, self.target, self.lineNumber, self.columnNumber, NSStringFromRange(self.range)];
}

- (BOOL)isEqual:(id)object {
    XMASObjcMethodCall *other = (XMASObjcMethodCall *)object;
    if (![other isKindOfClass:[XMASObjcMethodCall class]]) {
        return NO;
    }

    return self.range.length == other.range.length &&
        self.range.location == other.range.location &&
        self.lineNumber == other.lineNumber &&
        self.columnNumber == other.columnNumber &&
        [self.target isEqualToString:other.target] &&
        [self.filePath isEqualToString:other.filePath] &&
        [self.arguments isEqualToArray:other.arguments] &&
        [self.selectorComponents isEqualToArray:other.selectorComponents];
}

@end
