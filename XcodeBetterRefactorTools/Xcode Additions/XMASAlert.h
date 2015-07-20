#import <Foundation/Foundation.h>

@interface XMASAlert : NSObject
- (void)flashMessage:(NSString *)message;
- (void)flashComfortingMessageForException:(NSException *)exception;
@end
