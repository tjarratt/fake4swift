#import "XMASXcodeProjectFileRepository.h"
#import "XMASXcodeRepository.h"

@interface XMASXcodeProjectFileRepository ()

@property (nonatomic) XMASXcodeRepository *xcodeRepository;

@end


@implementation XMASXcodeProjectFileRepository

- (instancetype)initWithXcodeRepository:(XMASXcodeRepository *)xcodeRepository {
    if (self = [super init]) {
        _xcodeRepository = xcodeRepository;
    }

    return self;
}

- (BOOL)addFileToXcode:(NSString *)filePath
    alongsideFileNamed:(NSString *)relativeFilePath
             directory:(NSString *)directory
                 error:(NSError **)error {
    id group;
    id workspace = self.xcodeRepository.currentWorkspace;
    NSDictionary *fileRefsMap = (id)[workspace performSelector:@selector(_fileRefsToResolvedFilePaths)];

    NSString *fileName = relativeFilePath.lastPathComponent;
    for (id item in fileRefsMap.allKeys) {
        if ([[item name] isEqualToString:fileName]) {
            group = [item valueForKey:@"_superitem"];
            break;
        }
    }

    if (!group) {
        NSString *failureReason = [NSString stringWithFormat:@"Could not find any file named '%@'", fileName];
        NSDictionary *userInfo = @{
                                   NSLocalizedFailureReasonErrorKey: failureReason
                                   };
        *error = [NSError errorWithDomain:@"BetterRefactorToolsDomain" code:888 userInfo:userInfo];
        return NO;
    }

    id reference = [group reference];

    NSString *containingFile = [[[filePath stringByDeletingLastPathComponent]
                                 stringByDeletingLastPathComponent]
                                stringByAppendingPathComponent:directory];
    [reference addFiles:@[containingFile] copy:NO createGroupsRecursively:YES];

    return YES;
}

@end
