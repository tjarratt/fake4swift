#import <Foundation/Foundation.h>
#import "XcodeInterfaces.h"

NS_ASSUME_NONNULL_BEGIN

@interface FakeDVTFilePath : NSObject<NSCopying>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *filePath;
@property (nonatomic, readonly) id group;

- (instancetype)initWithGroup:(nullable id)group
                     filePath:(NSString *)pathString;

@end

@interface FakeXcodeFileReference : NSObject

- (instancetype)initWithFilePath:(NSString *)filePath;

- (FakeDVTFilePath *)resolvedFilePath;

@end

NS_ASSUME_NONNULL_END
