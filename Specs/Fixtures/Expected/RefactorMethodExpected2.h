#import <Foundation/Foundation.h>
@interface XMASAlert : NSObject
- (instancetype)initWithThis:(id)thisThing
                     andThat:(id<NSObject>)thatThing NS_DESIGNATED_INITIALIZER;
- (void)flashMessage:(NSString *)message;
@end
