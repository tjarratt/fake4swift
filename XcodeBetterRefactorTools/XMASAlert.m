#import "XMASAlert.h"

@interface XMASAlert (AlertClassDump)
- (id)initWithIcon:(id)icon
           message:(id)message
      parentWindow:(id)window
          duration:(double)duration;
- (void)orderFront:(id)sender;
@end

@implementation XMASAlert
- (void)flashMessage:(NSString *)message {
    id alertPanel =
        [[NSClassFromString(@"DVTBezelAlertPanel") alloc] initWithIcon:nil
                                                               message:message
                                                          parentWindow:nil
                                                              duration:2.0];
    [alertPanel orderFront:nil];
}
@end
