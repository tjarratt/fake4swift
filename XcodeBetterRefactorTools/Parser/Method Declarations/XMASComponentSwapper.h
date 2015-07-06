#import <Foundation/Foundation.h>

@interface XMASComponentPair : NSObject
@property (nonatomic, readonly) NSString *first;
@property (nonatomic, readonly) NSString *second;
@end

@interface XMASComponentSwapper : NSObject
- (XMASComponentPair *)swapComponent:(NSString *)first withComponent:(NSString *)second;
@end
