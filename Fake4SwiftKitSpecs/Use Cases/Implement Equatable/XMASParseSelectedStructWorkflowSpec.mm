#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>

#import "Fake4SwiftKitSpecs-Swift.h"
#import "Fake4SwiftKitModule.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASParseSelectedStructWorkflowSpec)

describe(@"XMASParseSelectedStructWorkflow", ^{
    __block XMASParseSelectedStructWorkflow *subject;
    __block id<XMASSelectedStructOracle> selectedStructOracle;

    NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"MySpecialStruct" ofType:@"swift"];

    beforeEach(^{
        id<BSModule> module = [Fake4SwiftKitModule new];
        id<BSInjector, BSBinder> injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:module];

        selectedStructOracle = nice_fake_for(@protocol(XMASSelectedStructOracle));
        [injector bind:@protocol(XMASSelectedStructOracle) toInstance:selectedStructOracle];

        subject = [injector getInstance:[XMASParseSelectedStructWorkflow class]];

        subject should_not be_nil;
    });

    context(@"when a swift struct is selected", ^{
        __block StructDeclaration *structDeclaration;
        beforeEach(^{
            selectedStructOracle stub_method(@selector(isStructSelected:))
                .and_return(YES);

            NSError *error = nil;
            structDeclaration = [subject selectedStructInFile:fixturePath error:&error];
            error should be_nil;
        });

        it(@"should parse the name of the struct", ^{
            structDeclaration.name should equal(@"MySpecialStruct");
        });

        it(@"should parse the field names in the struct", ^{
            structDeclaration.fieldNames should equal(@[@"name", @"age"]);
        });

        it(@"should ask its selected struct oracle if each struct is selected", ^{
            StructDeclaration *expectedStructDecl = [[StructDeclaration alloc] initWithName:@"MySpecialStruct"
                                                                                      range:NSMakeRange(19, 66)
                                                                                   filePath:fixturePath
                                                                                     fields:@[@"name", @"age"]];
            selectedStructOracle should have_received(@selector(isStructSelected:))
                .with(expectedStructDecl);
        });
    });

    context(@"when no swift struct is selected", ^{
        it(@"should throw an error", ^{
            selectedStructOracle stub_method(@selector(isStructSelected:))
                .and_return(NO);

            NSError *error = nil;
            StructDeclaration *decl = [subject selectedStructInFile:fixturePath error:&error];
            decl should be_nil;

            error should_not be_nil;
            error.localizedFailureReason should equal(@"No struct was selected");
        });
    });
});

SPEC_END
