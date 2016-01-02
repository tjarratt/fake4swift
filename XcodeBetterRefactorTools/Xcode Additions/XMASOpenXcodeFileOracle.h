#import <Foundation/Foundation.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit-Swift.h>

@interface XMASOpenXcodeFileOracle : NSObject<XMASSelectedSourceFileOracle>

- (NSString *)selectedFilePath;

@end
