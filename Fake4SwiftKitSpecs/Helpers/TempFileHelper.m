#import "TempFileHelper.h"

@implementation TempFileHelper

+ (NSString *)temporaryFilePathForFixture:(NSString *)fixtureName
                                   ofType:(NSString *)fixtureType {

    NSString *pathToFixture = [[NSBundle mainBundle] pathForResource:fixtureName ofType:fixtureType];

    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);

    NSString *temporaryFileName = [NSString stringWithFormat:@"%@-%@.%@", fixtureName, uuidStr, fixtureType];
    NSString *tempFixturePath = [NSTemporaryDirectory() stringByAppendingString:temporaryFileName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtPath:pathToFixture toPath:tempFixturePath error:nil];

    return tempFixturePath;
}

+ (NSString *)temporaryFilePathForFixture:(NSString *)fixtureName
                                   ofType:(NSString *)fixtureType
              withContainingDirectoryPath:(NSString *)containingDirectoryPath {

    NSString *pathToFixture = [[NSBundle mainBundle] pathForResource:fixtureName ofType:fixtureType];
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", fixtureName, fixtureType];

    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    NSString *temporaryDirectory = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), uuidStr];

    NSString *directoryContainingFixture = [NSString stringWithFormat:@"%@/%@", temporaryDirectory, containingDirectoryPath];

    NSString *tempFixturePath = [NSString stringWithFormat:@"%@/%@", directoryContainingFixture, fileName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:directoryContainingFixture withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager copyItemAtPath:pathToFixture toPath:tempFixturePath error:nil];

    return temporaryDirectory;
}

@end
