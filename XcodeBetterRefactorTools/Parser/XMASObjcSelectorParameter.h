#import <Foundation/Foundation.h>

@interface XMASObjcSelectorParameter : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithType:(NSString *)type
                   localName:(NSString *)localName NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *localName;

@end
