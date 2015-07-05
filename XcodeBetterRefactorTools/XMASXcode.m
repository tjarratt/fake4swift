#import "XMASXcode.h"

@implementation XMASXcode
+ (NSMenu *)menuWithTitle:(NSString *)title {
    return [[[NSApp mainMenu] itemWithTitle:title] submenu];
}
@end

@interface XMASXcode (WorkspaceClassDump)
- (id)editor;
- (id)editorArea;
- (id)lastActiveEditorContext;
@end

@implementation XMASXcode (Workspace)

#pragma mark - Workspaces

+ (XC(Workspace))currentWorkspace {
    return [(id)self.currentWorkspaceController valueForKey:@"_workspace"];
}

+ (XC(IDEWorkspaceWindowController))currentWorkspaceController {
    id workspaceController = [[NSApp keyWindow] windowController];
    if ([workspaceController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return workspaceController;
    } return nil;
}

#pragma mark - Editors

+ (id)currentEditor {
    id editorArea = [(id)self.currentWorkspaceController editorArea]; // IDEEditorArea
    id editorContext = [editorArea lastActiveEditorContext];          // IDEEditorContext
    return [editorContext editor];                                    // IDESourceCodeEditor, Xcode3ProjectEditor or IBDocumentEditor
}

#pragma mark Documents

+ (NSURL *)currentSourceCodeDocumentFileURL {
    id currentEditor = [XMASXcode currentEditor];
    if ([currentEditor respondsToSelector:@selector(sourceCodeDocument)]) {
        return [[currentEditor sourceCodeDocument] fileURL];
    }
    return nil;
}

+ (XC(IDEDocumentController))sharedDocumentController {
    return [NSClassFromString(@"IDEDocumentController") sharedDocumentController];
}

#pragma mark - Indexes

+ (XC(IDEIndex))indexForCurrentWorkspace {
    XC(IDEWorkspaceWindow) workspaceWindow;
    Class workspaceClass = NSClassFromString(@"IDEWorkspaceWindow");

    if ([workspaceClass respondsToSelector:(@selector(lastActiveWorkspaceWindow))]) {
        workspaceWindow = [workspaceClass lastActiveWorkspaceWindow];
    } else if ([workspaceClass respondsToSelector:@selector(lastActiveWorkspaceWindowController)]) {
        workspaceWindow = [[workspaceClass lastActiveWorkspaceWindowController] valueForKey:@"window"];
    }

    XC(IDEWorkspaceDocument) workspaceDocument = [workspaceWindow document];
    XC(IDEWorkspace) currentWorkspace = [workspaceDocument workspace];
    return [currentWorkspace index];
}

+ (id)instanceMethodSymbolKind {
    Class sourceCodeSymbolClass = NSClassFromString(@"DVTSourceCodeSymbolKind");
    return sourceCodeSymbolClass ? [sourceCodeSymbolClass instanceMethodSymbolKind] : nil;
}

@end
