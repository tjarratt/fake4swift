#import <Foundation/Foundation.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit-Swift.h>

@class XMASXcodeRepository;

NS_ASSUME_NONNULL_BEGIN

@interface XMASXcodeProjectFileRepository : NSObject<XMASAddFileToXcodeProjectWorkflow>

- (instancetype)initWithXcodeRepository:(XMASXcodeRepository *)xcodeRepository NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) XMASXcodeRepository *xcodeRepository;

@end

NS_ASSUME_NONNULL_END
