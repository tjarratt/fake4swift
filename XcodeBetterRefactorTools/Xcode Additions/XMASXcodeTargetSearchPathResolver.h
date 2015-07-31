#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

@interface XMASXcodeTargetSearchPathResolver : NSObject

- (NSArray *)effectiveHeaderSearchPathsForTarget:(XC(PBXTargetBuildContext))target;

@end

