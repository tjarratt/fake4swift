#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

@interface XMASSearchPathExpander : NSObject

- (NSArray *)expandSearchPaths:(XC(XCStringList))searchPaths forRootPath:(NSString *)rootPath;

@end
