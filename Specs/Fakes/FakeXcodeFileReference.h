#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

@interface FakeDVTFilePath : NSObject
@property (nonatomic, readonly) NSString *filePath;
@end

@interface FakeXcodeFileReference : NSObject

- (instancetype)initWithFilePath:(NSString *)filePath;
-(FakeDVTFilePath *)resolvedFilePath;

@end
