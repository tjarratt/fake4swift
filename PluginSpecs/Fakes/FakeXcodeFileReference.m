#import "FakeXcodeFileReference.h"
#import "XcodeInterfaces.h"

@interface FakeXcodeFileReference () <XCP(Xcode3FileReference)>
@property (nonatomic) FakeDVTFilePath *fakeDVTFilePath;
@end

@interface FakeDVTFilePath ()
@property (nonatomic) NSString *pathString;
@end

@implementation FakeDVTFilePath

- (instancetype)initWithFilePath:(NSString *)pathString {
    if (self = [super init]) {
        self.pathString = pathString;
    }
    return self;
}

@end

@implementation FakeXcodeFileReference

- (instancetype)initWithFilePath:(NSString *)filePath {
    if (self = [super init]) {
        self.fakeDVTFilePath = [[FakeDVTFilePath alloc] initWithFilePath:filePath];
    }

    return self;
}

-(FakeDVTFilePath *)resolvedFilePath {
    return self.fakeDVTFilePath;
}

@end

