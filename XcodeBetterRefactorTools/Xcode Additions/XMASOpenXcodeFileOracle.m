#import "XMASOpenXcodeFileOracle.h"
#import "XMASXcodeRepository.h"

@implementation XMASOpenXcodeFileOracle

- (NSString *)selectedFilePath {
    XMASXcodeRepository *xcodeRepository = [[XMASXcodeRepository alloc] init];
    id editor = [xcodeRepository currentEditor];
    
    if ([editor respondsToSelector:@selector(sourceCodeDocument)]) {
        return [[[editor sourceCodeDocument] fileURL] path];
    }
    return nil;
}

@end
