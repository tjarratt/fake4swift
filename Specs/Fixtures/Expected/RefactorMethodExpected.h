#import <Foundation/Foundation.h>
@interface XMASAlert : NSObject
- (void)flashMessage:(NSString *)message
            duration:(NSNumber *)duration;
@end
