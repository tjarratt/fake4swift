#import <Cocoa/Cocoa.h>

@class XMASRefactorMethodActionProvider;

@interface XMASEditMenu : NSObject
- (void)attach;
- (instancetype)initWithRefactorMethodActionProvider:(XMASRefactorMethodActionProvider *)actionProvider NS_DESIGNATED_INITIALIZER;

- (void)refactorCurrentMethodAction:(id)sender;
@end

@interface XMASEditMenu (UnavailableInitializers)

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
