#import "XMASXcodeTargetSearchPathResolver.h"

@implementation XMASXcodeTargetSearchPathResolver

- (NSArray *)effectiveHeaderSearchPathsForTarget:(id)target {
    id targetBuildContext = [target valueForKey:@"targetBuildContext"];
    NSDictionary * effectiveSearchPaths = [targetBuildContext valueForKey:@"effectiveSearchPaths"];
    NSArray *searchPathValues = [effectiveSearchPaths allValues];

    // get the array representation from each XCStringList and flatten the nested arrays
    return [[searchPathValues valueForKey:@"arrayRepresentation"] valueForKeyPath:@"@unionOfArrays.self"];
}

@end
