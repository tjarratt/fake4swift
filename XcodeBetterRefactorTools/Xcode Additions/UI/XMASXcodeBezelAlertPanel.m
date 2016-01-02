@import BetterRefactorToolsKit;

#import "XMASXcodeBezelAlertPanel.h"
#import "XcodeInterfaces.h"

@interface XMASXcodeBezelAlertPanel () <XMASAlerter>

@end


@implementation XMASXcodeBezelAlertPanel

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

- (void)flashComfortingMessageForError:(NSError *)error {
    [self flashMessage:@"Aww shucks. Something bad happened. Check Console.app"];

    NSLog(@"================> something bad happened. Perhaps this error will help explain it?");
    NSLog(@"================> %@", error.localizedFailureReason);
    NSLog(@"================> %@", error);
}

- (void)flashComfortingMessageForException:(NSException *)exception {
    [self flashMessage:@"Aww shucks. Something bad happened. Check Console.app"];

    NSLog(@"================> something bad happened. Perhaps this exception will help explain it?");
    NSLog(@"================> %@", [exception description]);
    NSLog(@"================> %@", [exception callStackSymbols]);
}

@end
