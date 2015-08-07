#import "XMASTokenizer.h"
#import <ClangKit/ClangKit.h>
#import "XMASXcode.h"
#import "XMASXcodeTargetSearchPathResolver.h"

@interface XMASTokenizer ()
@property (nonatomic) XMASXcodeTargetSearchPathResolver *searchPathResolver;
@end

@implementation XMASTokenizer

- (instancetype)initWithTargetSearchPathResolver:(XMASXcodeTargetSearchPathResolver *)searchPathResolver {
    if (self = [super init]) {
        self.searchPathResolver = searchPathResolver;
    }

    return self;
}

- (NSArray *)tokensForFilePath:(NSString *)filePath {
    NSArray *searchPathsForFile = @[];

    for (id target in [XMASXcode targetsInCurrentWorkspace]) {
        NSArray *buildFileReferences = [target allBuildFileReferences];
        if ([[buildFileReferences valueForKeyPath:@"resolvedFilePath.pathString"] containsObject:filePath]) {
            searchPathsForFile = [self.searchPathResolver effectiveHeaderSearchPathsForTarget:target];
        }
    }

    NSArray *args = [self argsForClangKitFromSearchPaths:searchPathsForFile];

    NSString *fileContents = [NSString stringWithContentsOfFile:filePath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];

    CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithText:fileContents
                                                                           language:CKLanguageObjCPP
                                                                               args:args];
    return translationUnit.tokens;
}

#pragma mark - Private

- (NSArray *)argsForClangKitFromSearchPaths:(NSArray *)searchPaths {
    NSMutableArray *args = [NSMutableArray arrayWithCapacity:searchPaths.count * 2];
    for (NSString *path in searchPaths) {
        [args addObject:[@"-F" stringByAppendingString:path]];
        [args addObject:[@"-I" stringByAppendingString:path]];
    }

    return [args copy];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

