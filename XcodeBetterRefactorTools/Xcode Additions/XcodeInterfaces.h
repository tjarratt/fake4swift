#import <Foundation/Foundation.h>

#define XCP(type) XMASXcode_##type
#define XC(type) id<XMASXcode_##type>

#pragma mark - Search Paths

@protocol XCP(XCStringList)
- (NSArray *)arrayRepresentation;
@end

#pragma mark - File References

@protocol XCP(DVTFilePath)
- (NSString *)pathString;
@end

@protocol XCP(Xcode3FileReference)
- (XC(DVTFilePath))resolvedFilePath;
@end

#pragma mark - Run contexts and destinations

@protocol XCP(RunContext)
- (BOOL)isTestable;
- (NSString *)name;
@end

@protocol XCP(RunDestination)
- (NSString *)fullDisplayName;
@end

@protocol XCP(RunContextManager)
- (XC(RunContext))activeRunContext;
- (NSArray *)runContexts;

- (XC(RunDestination))activeRunDestination;
- (NSArray *)availableRunDestinations;

- (void)setActiveRunContext:(XC(RunContext))context
    andRunDestination:(XC(RunDestination))destination;
@end

@protocol XCP(IDESchemeBuildableReference)

@end

@protocol XCP(IDEBuildSchemeAction)
- (id)buildActionEntries;
- (NSArray *)buildableReferences;
@end

@protocol XCP(IDEScheme)
- (XC(IDEBuildSchemeAction))buildSchemeAction;
@end

#pragma mark - Workspaces and editor areas

@protocol XCP(XCMacroExpansionScope)
- (instancetype)initWithParentScope:(id)something
               macroDefinitionTable:(id)something
                    definitionLevel:(NSInteger)defLevel
            definitionLevelsToClear:(NSInteger)defLevelsToClear
           conditionParameterValues:(id)something
                   expansionOptions:(id)something;
@end

@protocol XCP(PBXTargetBuildContext) <NSObject>
- (id)effectiveLibrarySearchPathsWithMacroExpansionScope:(id)scope;
- (id)effectiveFrameworkSearchPathsWithMacroExpansionScope:(id)scope;
- (id)effectiveUserHeaderSearchPathsWithMacroExpansionScope:(id)scope;
- (id)effectiveHeaderSearchPathsWithMacroExpansionScope:(id)scope;
@end

@protocol XCP(PBXNativeTarget)
- (id)cachedPropertyInfoContextForConfigurationNamed:(NSString *)name;
@end

@protocol XCP(Xcode3Target)
- (id)primaryBuildable;
- (id)buildables;
- (id)buildableProducts;
- (id)indexableFiles;
- (NSArray *)allBuildFileReferences;
@end

@protocol XCP(Workspace)
- (XC(RunContextManager))runContextManager;
- (XC(DVTFilePath))representingFilePath;
- (id)referencedBlueprints;
@end

@protocol XCP(IDEWorkspace);
@protocol XCP(IDEWorkspaceDocument)
- (XC(IDEWorkspace))workspace;
- (NSArray *)recentEditorDocumentURLs;
- (id)sdefSupport_fileReferences;
@end

@protocol XCP(IDEWorkspaceTabController)
- (XC(IDEWorkspaceDocument))workspaceDocument;
@end

@protocol XCP(IDEEditorArea)
- (id)lastActiveEditorContext;
@end

@protocol XCP(IDEWorkspaceWindowController)
- (XC(IDEEditorArea))editorArea;
- (XC(IDEWorkspaceTabController))activeWorkspaceTabController;
@end

#pragma mark - Session launching

@protocol XCP(IDELaunchParametersSnapshot)
// though env variables are exposed as NSDictionary* in Xcode headers
- (NSMutableDictionary *)environmentVariables;
- (NSMutableDictionary *)testingEnvironmentVariables;
@end

@protocol XCP(IDELaunchSession)
@property(retain) XC(IDELaunchParametersSnapshot) launchParameters;
@end


#pragma mark - Editors

@protocol XCP(DVTSourceExpression)
- (NSString *)symbolString;
- (NSRange)expressionRange;
@end

@protocol XCP(DVTSourceLandmarkItem)
- (NSRange)range;
- (NSString *)name;
@end

@protocol XCP(DVTSourceTextStorage)
- (NSString *)string;
- (NSArray *)importLandmarkItems;

- (NSUInteger)nextExpressionFromIndex:(unsigned long long)index
                              forward:(BOOL)forward;

- (void)replaceCharactersInRange:(NSRange)range
                      withString:(NSString *)string
                 withUndoManager:(id)undoManager;
@end

@protocol XCP(DVTTextDocumentLocation)
- (NSRange)characterRange;
@end

@protocol XCP(IDEEditorContext)
- (id)editor;
@end

@protocol XCP(IDESourceCodeDocument)
- (NSURL *)fileURL;
- (XC(DVTSourceTextStorage))textStorage;
- (id)undoManager;
@end

@protocol XCP(IDESourceCodeEditor)
- (XC(IDEEditorContext))editorContext;
- (XC(IDESourceCodeDocument))sourceCodeDocument;
- (XC(DVTSourceExpression))_expressionAtCharacterIndex:(NSRange)range;
- (NSArray *)currentSelectedDocumentLocations;
- (long long)_currentOneBasedLineNumber; // this selector was renamed at some unknown point
- (long long)_currentOneBasedLineNubmer; // this typo definitely existed prior to xcode 6
@end

#pragma mark - Symbols

@protocol XCP(DVTSourceCodeSymbolKind)
+ (id)containerSymbolKind;
+ (id)globalSymbolKind;
+ (id)callableSymbolKind;
+ (id)memberSymbolKind;
+ (id)memberContainerSymbolKind;
+ (id)categorySymbolKind;
+ (id)classMethodSymbolKind;
+ (id)classSymbolKind;
+ (id)enumSymbolKind;
+ (id)enumConstantSymbolKind;
+ (id)fieldSymbolKind;
+ (id)functionSymbolKind;
+ (id)instanceMethodSymbolKind;
+ (id)instanceVariableSymbolKind;
+ (id)classVariableSymbolKind;
+ (id)macroSymbolKind;
+ (id)parameterSymbolKind;
+ (id)propertySymbolKind;
+ (id)protocolSymbolKind;
+ (id)structSymbolKind;
+ (id)typedefSymbolKind;
+ (id)unionSymbolKind;
+ (id)localVariableSymbolKind;
+ (id)globalVariableSymbolKind;
+ (id)ibActionMethodSymbolKind;
+ (id)ibOutletSymbolKind;
+ (id)ibOutletVariableSymbolKind;
+ (id)ibOutletPropertySymbolKind;
+ (id)ibOutletCollectionSymbolKind;
+ (id)ibOutletCollectionVariableSymbolKind;
+ (id)ibOutletCollectionPropertySymbolKind;
+ (id)namespaceSymbolKind;
+ (id)classTemplateSymbolKind;
+ (id)functionTemplateSymbolKind;
+ (id)instanceMethodTemplateSymbolKind;
+ (id)classMethodTemplateSymbolKind;
+ (id)sourceCodeSymbolKinds;
@end

#pragma mark - Indexes

@protocol XCP(IDEIndex)
- (NSArray *)topLevelSymbolsInFile:(NSString *)filepath;
- (NSArray *)allSymbolsMatchingKind:(XC(DVTSourceCodeSymbolKind))symbolKind workspaceOnly:(BOOL)wonly;
- (NSArray *)allSymbolsMatchingName:(NSString *)arg1 kind:(XC(DVTSourceCodeSymbolKind))arg2;
@end

@protocol XCP(IDEIndexSymbol)
- (NSString *)name;
- (XC(IDEIndexSymbol))containerSymbol;
- (XC(DVTFilePath))file;
- (NSUInteger)lineNumber;
- (NSUInteger)column;
@end

@protocol XCP(IDEGeniusPackagedResults)
- (id)geniusResults;
@end

@protocol XCP(IDESourceCodeCallerGeniusResult)
- (id)valueForKey:(NSString *)key;
@end

#pragma mark - Workspace and Projects

@protocol XCP(IDEDocumentController)
+ (XC(IDEDocumentController))sharedDocumentController;
- (NSArray *)workspaceDocuments;
@end

@protocol XCP(IDEWorkspace)
- (XC(IDEIndex))index;
- (NSString *)name;
- (NSSet *)referencedContainers;
@end

@protocol XCP(IDEWorkspaceWindow)
- (XC(IDEWorkspaceDocument))document;
+ (XC(IDEWorkspaceWindow))lastActiveWorkspaceWindow;
+ (id)lastActiveWorkspaceWindowController;
@end

