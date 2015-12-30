#import <Foundation/Foundation.h>
@implementation XMASAlert
- (BOOL)flashMessage:(NSString *)message
           withDelay:(NSNumber *)delay {
    id alertPanel = [[DVTBezelAlertPanel alloc] initWithIcon:nil
                                                     message:message
                                                parentWindow:nil
                                                    duration:2.0];
    [alertPanel release];
}
@end
