@import BetterRefactorToolsKit;

#import "XMASXcodeBezelAlertPanel.h"
#import "XcodeInterfaces.h"

@interface XMASXcodeBezelAlertPanel () <XMASAlerter>

@end


@implementation XMASXcodeBezelAlertPanel

- (void)flashMessage:(NSString *)message
           withImage:(XMASAlertImage)imageName
    shouldLogMessage:(BOOL)shouldLogMessage {
    NSString *imagePath = [self resourcePathForAlertImage:imageName];

    id parentControl = [[NSImage alloc] initWithContentsOfFile:imagePath];

    id alertPanel =
    [[NSClassFromString(@"DVTBezelAlertPanel") alloc] initWithIcon:parentControl
                                                           message:message
                                                      parentWindow:nil
                                                          duration:2.0];
    [alertPanel orderFront:nil];


    if (shouldLogMessage) {
        NSLog(@"%@", message);
    }
}

- (void)flashComfortingMessageForError:(NSError *)error {
    NSString *message;
    if (error.localizedFailureReason) {
        message = error.localizedFailureReason;
    } else {
        message = @"Aww shucks. Something bad happened. Check Console.app";
    }

    [self flashMessage:message
             withImage:XMASAlertImageAbjectFailure
      shouldLogMessage:NO];

    NSLog(@"================> something bad happened. Perhaps this error will help explain it?");
    NSLog(@"================> %@", error.localizedFailureReason);
    NSLog(@"================> %@", error);
}

- (void)flashComfortingMessageForException:(NSException *)exception {
    [self flashMessage:@"Aww shucks. Something bad happened. Check Console.app"
             withImage:XMASAlertImageAbjectFailure
      shouldLogMessage:NO];

    NSLog(@"================> something bad happened. Perhaps this exception will help explain it?");
    NSLog(@"================> %@", [exception description]);
    NSLog(@"================> %@", [exception callStackSymbols]);
}

#pragma mark - Private

- (NSString *)resourcePathForAlertImage:(XMASAlertImage)imageName {
    switch (imageName) {
        case XMASAlertImageGeneratedFake:
            return [[NSBundle bundleForClass:[self class]] pathForResource:@"fake_mustache"
                                                                    ofType:@"png"];
        case XMASAlertImageImplementEquatable:
            return nil;
        case XMASAlertImageAbjectFailure:
            return [[NSBundle bundleForClass:[self class]] pathForResource:@"crushed_hand"
                                                                    ofType:@"png"];
        case XMASAlertImageNoSwiftFileSelected:
            return [[NSBundle bundleForClass:[self class]] pathForResource:@"ide_alert_bezel_test_failure"
                                                                    ofType:@"pdf"];
    }

    return nil;
}

@end
