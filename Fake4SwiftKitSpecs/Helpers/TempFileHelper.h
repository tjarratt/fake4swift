#import <Foundation/Foundation.h>

@interface TempFileHelper : NSObject

+ (NSString *)temporaryFilePathForFixture:(NSString *)fixtureName
                                   ofType:(NSString *)type;

+ (NSString *)temporaryFilePathForFixture:(NSString *)fixtureName
                                   ofType:(NSString *)fixtureType
              withContainingDirectoryPath:(NSString *)containingDirectoryPath;

@end
