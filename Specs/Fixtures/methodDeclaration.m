#import <Foundation/Foundation.h>

@interface XMASAlert ()

- (void)flashMessage:(NSString *)message;
- (NSString *)hideMessage;

@end


@implementation XMASAlert

- (void)flashMessage:(NSString *)message {
    id alertPanel = [[NSClassFromString(@"DVTBezelAlertPanel") alloc] initWithIcon:nil
                                                                           message:message
                                                                      parentWindow:nil
                                                                          duration:2.0];
                                                            [alertPanel orderFront:nil];
    [alertPanel release];
}

+ (NSString *)hideMessage {
    return nil;
}

@end
