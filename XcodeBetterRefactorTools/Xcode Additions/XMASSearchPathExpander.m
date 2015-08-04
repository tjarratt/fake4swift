#import "XMASSearchPathExpander.h"

@implementation XMASSearchPathExpander

- (NSArray *)expandSearchPaths:(XC(XCStringList))searchPaths forRootPath:(NSString *)rootPath {
    NSArray *searchPathsArray = [searchPaths arrayRepresentation];
    NSMutableArray *absoluteSearchPaths = [[NSMutableArray alloc] initWithCapacity:searchPathsArray.count];

    for (NSString *searchPath in searchPathsArray) {
        if ([[searchPath substringToIndex:1] isEqualToString:@"/"]) {
            [absoluteSearchPaths addObject:searchPath];
        } else {
            [absoluteSearchPaths addObject:[self constructAbsolutePathFor:searchPath withBase:rootPath]];
        }
    }

    return absoluteSearchPaths;
}

#pragma mark - Private

- (NSString *)constructAbsolutePathFor:(NSString *)relativePath withBase:(NSString *)basePath {
    // remove dir glob
    if ([basePath.lastPathComponent isEqualToString:@"**"]) {
        NSMutableArray *pathComponents = [[basePath pathComponents] mutableCopy];
        [pathComponents removeLastObject];
        basePath = [NSString pathWithComponents:pathComponents];
    }

    // check if relative path starts with the same directory as basePath, removing that if necessary
    if ([basePath.lastPathComponent isEqualToString:relativePath.pathComponents.firstObject]) {
        NSMutableArray *pathComponents = [[basePath pathComponents] mutableCopy];
        [pathComponents removeLastObject];
        basePath = [NSString pathWithComponents:pathComponents];
    }

    return [NSString pathWithComponents:@[basePath, relativePath]];
}

@end
