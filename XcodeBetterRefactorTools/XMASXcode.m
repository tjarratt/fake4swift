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

+ (XC(Workspace))currentWorkspace {
    return [(id)self.currentWorkspaceController valueForKey:@"_workspace"];
}

+ (XC(IDEWorkspaceWindowController))currentWorkspaceController {
    id workspaceController = [[NSApp keyWindow] windowController];
    if ([workspaceController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return workspaceController;
    } return nil;
}

+ (id)currentEditor {
    id editorArea = [(id)self.currentWorkspaceController editorArea]; // IDEEditorArea
    id editorContext = [editorArea lastActiveEditorContext];          // IDEEditorContext
    return [editorContext editor];                                    // IDESourceCodeEditor, Xcode3ProjectEditor or IBDocumentEditor
}

+ (NSURL *)currentSourceCodeDocumentFileURL {
    id currentEditor = [XMASXcode currentEditor];
    if ([currentEditor respondsToSelector:@selector(sourceCodeDocument)]) {
        return [[currentEditor sourceCodeDocument] fileURL];
    }
    return nil;
}

@end
