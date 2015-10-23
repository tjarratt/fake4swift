#import <Foundation/Foundation.h>

@interface XMASFakeProtocolPersister : NSObject

- (void)persistProtocolNamed:(NSString *)protocolName nearSourceFile:(NSString *)sourceFilePath;

@end
