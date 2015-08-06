#import "XMASRefactorMethodAction.h"
#import "XMASAlert.h"
#import "XcodeInterfaces.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASXcode.h"
#import <objc/runtime.h> // FIXME :: this should be removed eventually
#import "XMASTokenizer.h"

NSString * const noMethodSelected = @"No method selected. Put your cursor inside of a method declaration";

@interface XMASRefactorMethodAction () <XMASChangeMethodSignatureControllerDelegate>
@property (nonatomic) id currentEditor;
@property (nonatomic) XMASAlert *alerter;
@property (nonatomic) XMASTokenizer *tokenizer;
@property (nonatomic) XMASChangeMethodSignatureControllerProvider *controllerProvider;
@property (nonatomic) XMASObjcMethodDeclarationParser *methodDeclParser;

@property (nonatomic) XMASChangeMethodSignatureController *controller;

@end

@implementation XMASRefactorMethodAction

- (instancetype)initWithAlerter:(XMASAlert *)alerter
                      tokenizer:(XMASTokenizer *)tokenizer
             controllerProvider:(XMASChangeMethodSignatureControllerProvider *)controllerProvider
               methodDeclParser:(XMASObjcMethodDeclarationParser *)methodDeclParser {
    if (self = [super init]) {
        self.alerter = alerter;
        self.tokenizer = tokenizer;
        self.methodDeclParser = methodDeclParser;
        self.controllerProvider = controllerProvider;
    }

    return self;
}

- (void)setupWithEditor:(id)editor {
    self.currentEditor = editor;
}

- (void)hackyGetClangArgsForBuildables {
    XC(Workspace) workspace = [XMASXcode currentWorkspace];

    for (id target in [workspace referencedBlueprints]) {
        unsigned int countOfMethods = 0;

        if ([[target description] containsString:@"Cedar"]) {
            NSLog(@"================> cowardly skipping cedar target %@", target);
            continue;
        }

        // HERE BE THINGS WE NEED //
        // actual target that gets built by Xcode
        NSLog(@"================> %@", target);
        // references to the filepaths that are its translation units (Xcode3FileReference)
//        NSLog(@"================> %@", [target allBuildFileReferences]);

        // maybe this will give us the header search paths ???
//        NSLog(@"================> %@", [searchPathResolver effectiveHeaderSearchPathsForTarget:target]);

        // inspecting build context, trying to find -I and -F flags
        countOfMethods = 0;
        id context = [target valueForKey:@"targetBuildContext"];
        NSLog(@"================> target's build context %@", context);

//        NSLog(@"================> inspecting methods of target build context");
//        Class contextClass = [context class];
//        Method *methods = class_copyMethodList(contextClass, &countOfMethods);
//        for (NSUInteger index = 0; index < countOfMethods; ++index) {
//            NSLog(@"================> %s", sel_getName(method_getName(methods[index])));
//        }

        NSLog(@"================> context has a target ?? %@", [context valueForKey:@"target"]);

        // TODO :: try to find the framework / header search paths / user header search paths

        id nativeTarget = [context valueForKey:@"target"];
        id debugInfoContext = [nativeTarget cachedPropertyInfoContextForConfigurationNamed:@"debug"];
        NSLog(@"================> native target cached property context : %@", debugInfoContext);

//        // this is just the NSSet of all possible keys, it seems
//        id propertyDictionaries = [debugInfoContext valueForKey:@"allPropertyNamesInAllDictionaries"];
//        NSLog(@"================> property dictionaries : %@", propertyDictionaries);

//        NSLog(@"================> inspecting methods of macro expansion scope");
        Class klass = NSClassFromString(@"Xcode3FileReference");
        Method *methods = class_copyMethodList(klass, &countOfMethods);
        for (NSUInteger index = 0; index < countOfMethods; ++index) {
            NSLog(@"================> %s", sel_getName(method_getName(methods[index])));
        }
//        break;

//        id badScope = [[NSClassFromString(@"XCMacroExpansionScope") alloc] init];
        id badScope = [[NSClassFromString(@"XCMacroExpansionScope") alloc] initWithParentScope:nil macroDefinitionTable:nil definitionLevel:10 definitionLevelsToClear:0 conditionParameterValues:nil expansionOptions:nil];;
        NSLog(@"================> effective framework search paths %lu", [[context effectiveFrameworkSearchPathsWithMacroExpansionScope:badScope] count]);
        NSLog(@"================> effective user header search paths %lu", [[context effectiveUserHeaderSearchPathsWithMacroExpansionScope:badScope] count]);
        NSLog(@"================> effective header search paths %lu", [[context effectiveHeaderSearchPathsWithMacroExpansionScope:badScope] count]);
        NSLog(@"================> effective library search paths %lu", [[context effectiveLibrarySearchPathsWithMacroExpansionScope:badScope] count]);

//        id primaryBuildable = [target primaryBuildable];
//
//        if ([primaryBuildable conformsToProtocol:NSProtocolFromString(@"IDEBuildableProduct")]) {
//            NSLog(@"================> ZOMGGGGG primary buildable IS BUILDABLE");
//            NSLog(@"================> %@", [primaryBuildable valueForKey:@"productSettings"]);
//        }
//
//        NSLog(@"================> %@", [target primaryBuildable]);
//        NSLog(@"================> %@", [target buildables]);
//        NSLog(@"================> %@", [target buildableProducts]);
//        NSLog(@"================> %@", [target indexableFiles]);

//        break;
    }

//    XC(RunContextManager) runContextManager = [workspace runContextManager];
//    NSArray *schemes = [runContextManager runContexts];
//
//    NSLog(@"================> found some schemes :: %@", schemes);
//    for (XC(IDEScheme) scheme in schemes) {
//        XC(IDEBuildSchemeAction) buildAction = [scheme buildSchemeAction];
//        NSLog(@"================> %@", buildAction);
//
//        NSArray *buildableReferences = [buildAction buildableReferences];
//        for (XC(IDESchemeBuildableReference) buildableRef in buildableReferences) {
//
//        }
//    }
}

- (void)safelyRefactorMethodUnderCursor {

    [self hackyGetClangArgsForBuildables];

    @try {
        [self refactorMethodUnderCursor];
    }
    @catch (NSException *exception) {
        [self.alerter flashComfortingMessageForException:exception];
    }
}

- (void)refactorMethodUnderCursor {
    NSUInteger cursorLocation = [self cursorLocation];
    NSString *currentFilePath = [self currentSourceCodeFilePath];

    NSArray *tokens = [self.tokenizer tokensForFilePath:currentFilePath];
    NSLog(@"================> tokens from our brand new tokenizer :: %@", tokens);
    NSArray *selectors = [self.methodDeclParser parseMethodDeclarationsFromTokens:tokens];

    XMASObjcMethodDeclaration *selectedMethod;
    for (XMASObjcMethodDeclaration *selector in selectors) {
        if (cursorLocation > selector.range.location && cursorLocation < selector.range.location + selector.range.length) {
            selectedMethod = selector;
            break;
        }
    }

    if (!selectedMethod) {
        [self.alerter flashMessage:noMethodSelected];
        return;
    }

    self.controller = [self.controllerProvider provideInstanceWithDelegate:self];
    [self.controller refactorMethod:selectedMethod inFile:currentFilePath];
}

#pragma mark - <XMASChangeMethodSignatureControllerDelegate>

- (void)controllerWillDisappear:(XMASChangeMethodSignatureController *)controller {
    self.controller = nil;
}

#pragma mark - editor helpers

- (NSString *)currentSourceCodeFilePath {
    if ([self.currentEditor respondsToSelector:@selector(sourceCodeDocument)]) {
        return [[[self.currentEditor sourceCodeDocument] fileURL] path];
    }
    return nil;
}

- (NSUInteger)cursorLocation {
    id currentLocation = [[self.currentEditor currentSelectedDocumentLocations] lastObject];
    if ([currentLocation respondsToSelector:@selector(characterRange)]) {
        return [currentLocation characterRange].location;
    }

    return UINT_MAX;
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
