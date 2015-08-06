#import "XMASXcodeTargetSearchPathResolver.h"
#import "XMASSearchPathExpander.h"

@interface XMASXcodeTargetSearchPathResolver ()
@property (nonatomic) XMASSearchPathExpander *pathExpander;
@end

@implementation XMASXcodeTargetSearchPathResolver

- (instancetype)initWithPathExpander:(XMASSearchPathExpander *)pathExpander {
    if (self = [super init]) {
        self.pathExpander = pathExpander;
    }

    return self;
}

- (NSArray *)effectiveHeaderSearchPathsForTarget:(XC(PBXTargetBuildContext))target {
    id targetBuildContext = [(id)target valueForKey:@"targetBuildContext"];
    NSDictionary * effectiveSearchPaths = [targetBuildContext valueForKey:@"effectiveSearchPaths"];

    NSMutableArray *paths = [NSMutableArray array];
    for (NSString *rootPathKey in effectiveSearchPaths) {
        NSArray *expandedSearchPaths = [self.pathExpander expandSearchPaths:effectiveSearchPaths[rootPathKey]
                                                                forRootPath:rootPathKey];
        [paths addObjectsFromArray:expandedSearchPaths];
    }

    return paths;
}


#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
