#import "XMASSelectedTextProxy.h"
#import "XMASXcodeRepository.h"
#import <SourceKitten/SourceKitten.h>

@implementation XMASSelectedTextProxy

- (NSString *)selectedProtocolInFile:(NSString *)filePath {
    XMASXcodeRepository *xcodeRepository = [[XMASXcodeRepository alloc] init];

    id editor = [xcodeRepository currentEditor];

    id currentLocation = [[editor currentSelectedDocumentLocations] lastObject];
    if (![currentLocation respondsToSelector:@selector(characterRange)]) {
        return nil;
    }

    NSRange selectedRange = [currentLocation characterRange];

    Sour
    //

    return nil;
}

@end
