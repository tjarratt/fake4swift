#import <Foundation/Foundation.h>

@class XMASXcodeRepository;
@class XMASXcodeTargetSearchPathResolver;

@interface XMASTokenizer : NSObject

- (instancetype)initWithTargetSearchPathResolver:(XMASXcodeTargetSearchPathResolver *)searchPathResolver
                                 xcodeRepository:(XMASXcodeRepository *)xcodeRepository NS_DESIGNATED_INITIALIZER;

- (NSArray *)tokensForFilePath:(NSString *)filePath;

@end

@interface XMASTokenizer (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end
