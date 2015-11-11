#import "XMASFakeProtocolPersister.h"
#import "SwiftCompatibilityHeader.h"

@interface XMASFakeProtocolPersister ()
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) XMASSwiftProtocolFaker *protocolFaker;
@end

@implementation XMASFakeProtocolPersister

- (instancetype)initWithProtocolFaker:(XMASSwiftProtocolFaker *)protocolFaker
                          fileManager:(NSFileManager *)fileManager {
    if (self = [super init]) {
        self.fileManager = fileManager;
        self.protocolFaker = protocolFaker;
    }

    return self;
}

- (void)persistFakeForProtocol:(ProtocolDeclaration *)protocolDecl
                nearSourceFile:(NSString *)sourceFilePath {
    // get dir for source file path
    NSString *dirContainingSource = [sourceFilePath stringByDeletingLastPathComponent];
    NSString *fakesDir = [dirContainingSource stringByAppendingPathComponent:@"fakes"];

    // create ^^/fakes if it does not exist
    BOOL dirExists = [self.fileManager fileExistsAtPath:fakesDir isDirectory:nil];
    if (!dirExists) {
        [self.fileManager createDirectoryAtPath:fakesDir withIntermediateDirectories:YES attributes:nil error:nil];
    }

    // create fake for protocol
    NSError *error = nil;
    NSData *fileContents = [[self.protocolFaker fakeForProtocol:protocolDecl error:&error] dataUsingEncoding:NSUTF8StringEncoding];
    if (error != nil) {
        NSString *failureReason = error.localizedFailureReason;
        [[NSException exceptionWithName:@"" reason:failureReason userInfo:nil] raise];
    }

    NSString *fakeFileName = [[@"Fake" stringByAppendingString:protocolDecl.name] stringByAppendingString:@".swift"];
    NSString *pathToFake = [fakesDir stringByAppendingPathComponent:fakeFileName];

    // write out file contents into ^^/fakes/fake_blah_blah_blah.swift
    [self.fileManager createFileAtPath:pathToFake
                              contents:fileContents
                            attributes:nil];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
