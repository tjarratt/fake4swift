#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XMASAlertImage) {
    XMASAlertImageGeneratedFake,
    XMASAlertImageImplementEquatable,
    XMASAlertImageNoSwiftFileSelected,
    XMASAlertImageAbjectFailure
};

@protocol XMASAlerter <NSObject>

- (void)flashMessage:(NSString *)message
           withImage:(XMASAlertImage)imageName
    shouldLogMessage:(BOOL)shouldLogMessage;

- (void)flashComfortingMessageForError:(NSError *)error;
- (void)flashComfortingMessageForException:(NSException *)exception;

@end
