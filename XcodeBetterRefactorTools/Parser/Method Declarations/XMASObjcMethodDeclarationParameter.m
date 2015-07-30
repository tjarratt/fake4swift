#import "XMASObjcMethodDeclarationParameter.h"

@interface XMASObjcMethodDeclarationParameter ()
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *localName;
@end

@implementation XMASObjcMethodDeclarationParameter

- (instancetype)initWithType:(NSString *)type localName:(NSString *)localName {
    if (self = [super init]) {
        self.type = type;
        self.localName = localName;
    }

    return self;
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
