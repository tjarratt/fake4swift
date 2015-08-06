#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

@class XMASSearchPathExpander;

@interface XMASXcodeTargetSearchPathResolver : NSObject

- (instancetype)initWithPathExpander:(XMASSearchPathExpander *)pathExpander NS_DESIGNATED_INITIALIZER;
- (NSArray *)effectiveHeaderSearchPathsForTarget:(XC(PBXTargetBuildContext))target;

@end

@interface XMASXcodeTargetSearchPathResolver (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

