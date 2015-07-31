#import "XMASXcodeTargetSearchPathResolver.h"

@implementation XMASXcodeTargetSearchPathResolver

// this gives us the USER Header search paths
- (NSArray *)effectiveHeaderSearchPathsForTarget:(id)target {
    return [[[[[target valueForKey:@"targetBuildContext"] valueForKey:@"effectiveSearchPaths"] allValues] valueForKey:@"arrayRepresentation"] valueForKeyPath:@"@unionOfArrays.self"];
}

@end
