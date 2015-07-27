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
    [self flashMessage:message withLogging:NO];
}

- (void)flashMessage:(NSString *)message withLogging:(BOOL)shouldLogMessage {
    id alertPanel =
        [[NSClassFromString(@"DVTBezelAlertPanel") alloc] initWithIcon:nil
                                                               message:message
                                                          parentWindow:nil
                                                              duration:2.0];
    [alertPanel orderFront:nil];

    if (shouldLogMessage) {
        NSLog(@"%@", message);
    }
}

- (void)flashComfortingMessageForException:(NSException *)exception {
    [self flashMessage:@"Aww shucks. Something bad happened. Check Console.app"];
    NSLog(@"================> something bad happened. Perhaps this exception will help explain it?");
    NSLog(@"================> %@", [exception description]);
    NSLog(@"================> %@", [exception callStackSymbols]);
}

@end
