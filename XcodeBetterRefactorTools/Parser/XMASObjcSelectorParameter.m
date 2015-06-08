#import "XMASObjcSelectorParameter.h"

@interface XMASObjcSelectorParameter ()
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *localName;
@end

@implementation XMASObjcSelectorParameter

- (instancetype)initWithType:(NSString *)type localName:(NSString *)localName {
    if (self = [super init]) {
        self.type = type;
        self.localName = localName;
    }

    return self;
}

@end
