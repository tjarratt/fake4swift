#import <Foundation/Foundation.h>

@class XMASWindowProvider;
@class XMASChangeMethodSignatureController;

@protocol XMASChangeMethodSignatureControllerDelegate;

@interface XMASChangeMethodSignatureControllerProvider : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider NS_DESIGNATED_INITIALIZER;

- (XMASChangeMethodSignatureController *)provideInstanceWithDelegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate;

@end
