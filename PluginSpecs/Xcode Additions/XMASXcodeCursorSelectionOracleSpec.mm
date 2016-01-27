#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit-Swift.h>

#import "PluginSpecs-Swift.h"
#import "RefactorToolsModule.h"
#import "XMASXcodeRepository.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASXcodeCursorSelectionOracleSpec)

describe(@"XMASXcodeCursorSelectionOracle", ^{
    __block XMASXcodeCursorSelectionOracle *subject;
    __block XMASXcodeRepository *fakeXcodeRepository;

    beforeEach(^{
        NSArray *modules = @[[[RefactorToolsModule alloc] init]];
        id<BSInjector, BSBinder> injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModules:modules];

        fakeXcodeRepository = nice_fake_for([XMASXcodeRepository class]);
        fakeXcodeRepository stub_method(@selector(cursorSelectionRange))
            .and_return(NSMakeRange(55, 12));
        [injector bind:[XMASXcodeRepository class] toInstance:fakeXcodeRepository];

        subject = [injector getInstance:@protocol(XMASSelectedProtocolOracle)];
    });

    describe(@"protocols", ^{
        ProtocolDeclaration *selectedProtocol = [[ProtocolDeclaration alloc] initWithName:@""
                                                                           containingFile:@""
                                                                              rangeInFile:NSMakeRange(50, 20)
                                                                            usesTypealias:NO
                                                                        includedProtocols:@[]
                                                                          instanceMethods:@[]
                                                                            staticMethods:@[]
                                                                          mutatingMethods:@[]
                                                                             initializers:@[]
                                                                                  getters:@[]
                                                                                  setters:@[]
                                                                            staticGetters:@[]
                                                                            staticSetters:@[]
                                                                         subscriptGetters:@[]
                                                                         subscriptSetters:@[]];
        ProtocolDeclaration *otherProtocol = [[ProtocolDeclaration alloc] initWithName:@""
                                                                        containingFile:@""
                                                                           rangeInFile:NSMakeRange(10, 20)
                                                                         usesTypealias:NO
                                                                     includedProtocols:@[]
                                                                       instanceMethods:@[]
                                                                         staticMethods:@[]
                                                                       mutatingMethods:@[]
                                                                          initializers:@[]
                                                                               getters:@[]
                                                                               setters:@[]
                                                                         staticGetters:@[]
                                                                         staticSetters:@[]
                                                                      subscriptGetters:@[]
                                                                      subscriptSetters:@[]];

        it(@"knows they are selected when the protocol's range overlaps with xcode's cursor", ^{
            [subject isProtocolSelected:selectedProtocol] should be_truthy;
        });

        it(@"knows they are not seleted when the protocol's range does not overlap with xcode's cursor", ^{
            [subject isProtocolSelected:otherProtocol] should be_falsy;
        });
    });

    describe(@"structs", ^{
        StructDeclaration *selectedStruct = [[StructDeclaration alloc] initWithName:@"MySpecialStruct"
                                                                              range:NSMakeRange(50, 20)
                                                                           filePath:@"sup"
                                                                             fields:@[]];
        StructDeclaration *otherStruct = [[StructDeclaration alloc] initWithName:@"Whoops"
                                                                           range:NSMakeRange(20, 20)
                                                                        filePath:@"sup"
                                                                          fields:@[]];

        it(@"knows they are selected when the struct's range overlaps with xcode's cursor", ^{
            [subject isStructSelected:selectedStruct] should be_truthy;
        });

        it(@"knows they are not seleted when the structs's range does not overlap with xcode's cursor", ^{
            [subject isStructSelected:otherStruct] should be_falsy;
        });
    });
});

SPEC_END
