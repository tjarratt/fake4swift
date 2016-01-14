#import "FakeXcodeFileReference.h"
#import "XcodeInterfaces.h"

@interface FakeXcodeFileReference () <XCP(Xcode3FileReference)>
@property (nonatomic) FakeDVTFilePath *fakeDVTFilePath;
@end

@interface FakeDVTFilePath ()
@property (nonatomic, nullable) id group;
@property (nonatomic) NSString *pathString;
@end


#pragma mark - FakeDVTFilePath

@implementation FakeDVTFilePath

- (instancetype)initWithGroup:(nullable id)group
                     filePath:(NSString *)pathString {
    if (self = [super init]) {
        self.group = group;
        self.pathString = pathString;
    }
    return self;
}

- (NSString *)name {
    return self.pathString.lastPathComponent;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[FakeDVTFilePath alloc] initWithGroup:self.group
                                         filePath:[self.pathString copy]];
}

- (id)_superitem {
    return self.group;
}

@end


#pragma mark - FakeXcodeFileReference

@implementation FakeXcodeFileReference

- (instancetype)initWithFilePath:(NSString *)filePath {
    if (self = [super init]) {
        self.fakeDVTFilePath = [[FakeDVTFilePath alloc] initWithGroup:nil filePath:filePath];
    }

    return self;
}

-(FakeDVTFilePath *)resolvedFilePath {
    return self.fakeDVTFilePath;
}

- (id)reference {
    return nil;
}

@end

