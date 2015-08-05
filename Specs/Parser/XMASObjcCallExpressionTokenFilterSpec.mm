#import <Cedar/Cedar.h>
#import <ClangKit/ClangKit.h>
#import "XMASObjcCallExpressionTokenFilter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcCallExpressionTokenFilterSpec)

describe(@"XMASObjcCallExpressionTokenFilter", ^{
    NSString *methodDeclarationFixture = [[NSBundle mainBundle] pathForResource:@"MethodDeclaration" ofType:@"m"];
    NSArray *methodDeclarationTokens = [[CKTranslationUnit translationUnitWithPath:methodDeclarationFixture] tokens];

    NSString *nestedCallExpressionsFixture = [[NSBundle mainBundle] pathForResource:@"NestedCallExpressions" ofType:@"m"];
    NSArray *nestedCallExpressionTokens = [[CKTranslationUnit translationUnitWithPath:nestedCallExpressionsFixture] tokens];

    describe(@"-parseAllCallExpressionsFromTokens:", ^{
        XMASObjcCallExpressionTokenFilter *subject = [[XMASObjcCallExpressionTokenFilter alloc] init];
        it(@"should parse the range of each call expression in the array of tokens", ^{
            NSSet *callExprRanges = [subject parseCallExpressionRangesFromTokens:methodDeclarationTokens];
            callExprRanges should equal([NSSet setWithObjects:
                                         [NSValue valueWithRange:NSMakeRange(53, 22)],
                                         [NSValue valueWithRange:NSMakeRange(54, 8)],
                                         [NSValue valueWithRange:NSMakeRange(76, 6)],
                                         [NSValue valueWithRange:NSMakeRange(83, 4)],
                                         nil]);
        });

        it(@"should be able to parse nested call expressions", ^{
            NSSet *callExprRanges = [subject parseCallExpressionRangesFromTokens:nestedCallExpressionTokens];
            callExprRanges should contain([NSValue valueWithRange:NSMakeRange(129, 6)]);
            callExprRanges should contain([NSValue valueWithRange:NSMakeRange(137, 6)]);
            callExprRanges should contain([NSValue valueWithRange:NSMakeRange(145, 6)]);
            callExprRanges should contain([NSValue valueWithRange:NSMakeRange(153, 6)]);
        });
    });

    describe(@"finding call expressions in Cedar specs", ^{
        NSString *cedarSpecFixture = [[NSBundle mainBundle] pathForResource:@"CedarSpecFixture" ofType:@"mm"];
        NSString *fixtureContents = [NSString stringWithContentsOfFile:cedarSpecFixture
                                                          encoding:NSUTF8StringEncoding
                                                                 error:nil];

        NSArray *args = @[
//                          @"-I/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers",
//                          @"-I/Users/pivotal/Library/Developer/Xcode/DerivedData/XcodeBetterRefactorTools-cfcizzpibplavhazstbostobarkk/Build/Intermediates/XcodeBetterRefactorTools.build/Debug/Specs.build/Specs-own-target-headers.hmap",
//                          @"-I/Users/pivotal/Library/Developer/Xcode/DerivedData/XcodeBetterRefactorTools-cfcizzpibplavhazstbostobarkk/Build/Intermediates/XcodeBetterRefactorTools.build/Debug/Specs.build/Specs-all-target-headers.hmap",
//                          @"-iquote /Users/pivotal/Library/Developer/Xcode/DerivedData/XcodeBetterRefactorTools-cfcizzpibplavhazstbostobarkk/Build/Intermediates/XcodeBetterRefactorTools.build/Debug/Specs.build/Specs-project-headers.hmap",
//                          @"-I/Users/pivotal/Library/Developer/Xcode/DerivedData/XcodeBetterRefactorTools-cfcizzpibplavhazstbostobarkk/Build/Products/Debug/include",
//                          @"-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include",
//                          @"-I/Users/pivotal/Library/Developer/Xcode/DerivedData/XcodeBetterRefactorTools-cfcizzpibplavhazstbostobarkk/Build/Intermediates/XcodeBetterRefactorTools.build/Debug/Specs.build/DerivedSources/x86_64",
//                          @"-I/Users/pivotal/Library/Developer/Xcode/DerivedData/XcodeBetterRefactorTools-cfcizzpibplavhazstbostobarkk/Build/Intermediates/XcodeBetterRefactorTools.build/Debug/Specs.build/DerivedSources",

                          @"-F/Users/pivotal/Library/Developer/Xcode/DerivedData/XcodeBetterRefactorTools-cfcizzpibplavhazstbostobarkk/Build/Products/Debug",

//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/CedarPlugin.xcplugin",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/CodeSnippetsAndTemplates",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/iOSSpecs",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/OCUnitApp",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/OCUnitAppLogicTests",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/OCUnitAppTests",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/XCUnitAppTests",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/CedarPlugin.xcplugin/Contents",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/CodeSnippetsAndTemplates/AppCodeSnippets",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/CodeSnippetsAndTemplates/CodeSnippets",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/CodeSnippetsAndTemplates/Templates",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/iOSSpecs/Images.xcassets",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Doubles",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Extensions",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/iPhone",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Matchers",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/ReporterHelpers",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Reporters",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Doubles",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Focused",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/iOSFrameworkSpecs",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/iPhone",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Matchers",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Reporters",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Resources",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Support",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/CedarPlugin.xcplugin/Contents/MacOS",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/iOSSpecs/Images.xcassets/AppIcon.appiconset",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/iOSSpecs/Images.xcassets/LaunchImage.launchimage",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Doubles/Arguments",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Doubles",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Extensions",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/iPhone",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Matchers",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Reporters",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/iPhone/XCTest",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Matchers/Base",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Matchers/Stringifiers",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/iPhone/XCTest",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Matchers/Base",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Matchers/Container",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Matchers/OSX",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Matchers/UIKit",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Spec/Support/GData",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Doubles/Arguments",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Matchers/Base",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Matchers/Comparators",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Matchers/Container",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Matchers/OSX",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Matchers/Stringifiers",
//                          @"-F/Users/pivotal/workspace/tjarratt/xcode-better-refactor-tools/Externals/Cedar/Source/Headers/Matchers/UIKit",
                          ];
        CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithText:fixtureContents
                                                                               language:CKLanguageObjCPP
                                                                                   args:args];
        NSArray *cedarSpecTokens = [translationUnit tokens];

        it(@"should be fine", ^{
            cedarSpecTokens should equal(@[]);
        });
    });
});

SPEC_END
