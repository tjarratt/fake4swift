#import <Foundation/Foundation.h>
@implementation XMASAlert
- (void)flashMessage:(NSString *)message {
    id alertPanel = [[DVTBezelAlertPanel alloc] initWithIcon:nil
                                                     message:message
                                                parentWindow:nil
                                                    duration:2.0
                                                 newArgument:nil];
    [alertPanel release];
}
@end