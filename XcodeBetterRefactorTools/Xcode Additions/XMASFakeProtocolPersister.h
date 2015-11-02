#import <Foundation/Foundation.h>

@class XMASSwiftProtocolFaker;
@class ProtocolDeclaration;

@interface XMASFakeProtocolPersister : NSObject

@property (nonatomic, strong, readonly) NSFileManager *fileManager;
@property (nonatomic, strong, readonly) XMASSwiftProtocolFaker *protocolFaker;

- (instancetype)initWithProtocolFaker:(XMASSwiftProtocolFaker *)protocolFaker
                          fileManager:(NSFileManager *)fileManager NS_DESIGNATED_INITIALIZER;
- (void)persistFakeForProtocol:(ProtocolDeclaration *)protocolDecl
                nearSourceFile:(NSString *)sourceFilePath;

@end

@interface XMASFakeProtocolPersister (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end
