#import <Foundation/Foundation.h>

@protocol XMASAlerter <NSObject>

- (void)flashMessage:(NSString *)message;
- (void)flashMessage:(NSString *)message withLogging:(BOOL)shouldLogMessage;
- (void)flashComfortingMessageForException:(NSException *)exception;

@end
