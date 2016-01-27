#import <Foundation/Foundation.h>
#import <Blindside/Blindside.h>

@interface XMASEditMenu : NSObject

- (instancetype)initWithInjector:(id<BSInjector>)injector NS_DESIGNATED_INITIALIZER;
- (void)attach;

- (void)generateFakeAction:(id)sender;
- (void)implementEquatableAction:(id)sender;
- (void)refactorCurrentMethodAction:(id)sender;

@end

@interface XMASEditMenu (UnavailableInitializers)

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
