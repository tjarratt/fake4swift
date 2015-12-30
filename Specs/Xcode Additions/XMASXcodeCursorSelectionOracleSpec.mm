#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
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

    it(@"returns YES when the protocol's range overlaps with xcode's cursor", ^{
        [subject isProtocolSelected:selectedProtocol] should be_truthy;
    });

    it(@"returns NO when the protocol's range does not overlap with xcode's cursor", ^{
        [subject isProtocolSelected:otherProtocol] should be_falsy;
    });
});

SPEC_END
