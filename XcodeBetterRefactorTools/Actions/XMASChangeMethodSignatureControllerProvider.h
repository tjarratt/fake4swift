#import <Foundation/Foundation.h>

@class XMASWindowProvider;
@class XMASChangeMethodSignatureController;

@interface XMASChangeMethodSignatureControllerProvider : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider NS_DESIGNATED_INITIALIZER;

- (XMASChangeMethodSignatureController *)provideInstance;

@end
