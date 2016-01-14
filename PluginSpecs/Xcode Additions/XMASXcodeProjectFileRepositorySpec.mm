#import <Cedar/Cedar.h>
#import "XMASXcodeProjectFileRepository.h"
#import "XMASXcodeRepository.h"
#import "XcodeInterfaces.h"
#import "FakeXcodeFileReference.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASXcodeProjectFileRepositorySpec)

describe(@"XMASXcodeProjectFileRepository", ^{
    __block XMASXcodeProjectFileRepository *subject;
    __block XMASXcodeRepository *xcodeRepo;

    beforeEach(^{
        xcodeRepo = nice_fake_for([XMASXcodeRepository class]);
        subject = [[XMASXcodeProjectFileRepository alloc] initWithXcodeRepository:xcodeRepo];
    });

    describe(@"-addFileToXcode:directory:error:", ^{
        __block NSError *error;
        __block XC(Workspace) workspace;

        subjectAction(^{
            [subject addFileToXcode:@"/my/special/fakes/Faketestfile.swift"
                 alongsideFileNamed:@"/my/special/testfile.swift"
                          directory:@"fakes"
                              error:&error];
        });

        beforeEach(^{
            workspace = nice_fake_for(@protocol(XCP(Workspace)));
            xcodeRepo stub_method(@selector(currentWorkspace))
                .and_return(workspace);
        });

        context(@"when there is a matching file reference for the one being added", ^{
            __block XC(PBXGroup) parentGroup;

            beforeEach(^{
                error = nil;

                XC(Xcode3FileReference) group = nice_fake_for(@protocol(XCP(Xcode3FileReference)));
                parentGroup = nice_fake_for(@protocol(XCP(PBXGroup)));
                group stub_method(@selector(reference)).and_return(parentGroup);

                FakeDVTFilePath *key = [[FakeDVTFilePath alloc] initWithGroup:group
                                                                     filePath:@"/my/special/testfile.swift"];
                NSDictionary *value = @{@"_superitem": [NSNull null]};

                workspace stub_method(@selector(_fileRefsToResolvedFilePaths)).and_return(@{key: value});
            });

            it(@"should not fail", ^{
                error should be_nil;
            });

            it(@"should ask the parent group to add a files, adding the generated fake as a side-effect", ^{
                parentGroup should have_received(@selector(addFiles:copy:createGroupsRecursively:))
                    .with(@[@"/my/special/fakes"], NO, YES);
            });
        });

        context(@"when there is no matching file reference", ^{
            beforeEach(^{
                workspace stub_method(@selector(_fileRefsToResolvedFilePaths)).and_return(@{});
            });

            it(@"should return an error", ^{
                error should_not be_nil;
            });
        });
    });
});

SPEC_END
