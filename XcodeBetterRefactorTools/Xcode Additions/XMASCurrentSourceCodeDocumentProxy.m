#import "XMASCurrentSourceCodeDocumentProxy.h"
#import "XMASXcodeRepository.h"

@implementation XMASCurrentSourceCodeDocumentProxy

- (NSString *)currentSourceCodeFilePath {
    XMASXcodeRepository *xcodeRepository = [[XMASXcodeRepository alloc] init];
    id editor = [xcodeRepository currentEditor];
    
    if ([editor respondsToSelector:@selector(sourceCodeDocument)]) {
        return [[[editor sourceCodeDocument] fileURL] path];
    }
    return nil;
}

@end
