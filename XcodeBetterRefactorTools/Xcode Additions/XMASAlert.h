#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMASAlert : NSObject

- (void)flashMessage:(NSString *)message;
- (void)flashMessage:(NSString *)message withLogging:(BOOL)shouldLogMessage;
- (void)flashComfortingMessageForException:(NSException *)exception;

@end

NS_ASSUME_NONNULL_END