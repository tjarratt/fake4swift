#import <Foundation/Foundation.h>
@interface XMASAlert : NSObject
- (instancetype)initWithThis:(id)thisThing NS_DESIGNATED_INITIALIZER;
- (void)flashMessage:(NSString *)message;
@end
