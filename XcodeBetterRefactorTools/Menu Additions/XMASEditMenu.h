#import <Foundation/Foundation.h>
#import <Blindside/Blindside.h>

@interface XMASEditMenu : NSObject
- (void)attach;
- (void)refactorCurrentMethodAction:(id)sender;
- (void)generateFakeAction:(id)sender;

- (instancetype)initWithInjector:(id<BSInjector>)injector NS_DESIGNATED_INITIALIZER;
@end

@interface XMASEditMenu (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end
