#import <Cedar/Cedar.h>
#import "XMASChangeMethodSignatureController.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASWindowProvider.h"
#import "XMASAlert.h"
#import "XMASMethodOccurrencesRepository.h"
#import "XMASObjcCallExpressionRewriter.h"
#import "XMASObjcMethodDeclarationRewriter.h"
#import "XMASObjcMethodDeclarationStringWriter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASChangeMethodSignatureControllerSpec)

describe(@"XMASChangeMethodSignatureController", ^{
    __block NSWindow *window;
    __block XMASAlert *alerter;
    __block XMASWindowProvider <CedarDouble> *windowProvider;
    __block XMASChangeMethodSignatureController *subject;
    __block XMASMethodOccurrencesRepository *methodOccurrencesRepository;
    __block XMASObjcCallExpressionRewriter *callExpressionRewriter;
    __block XMASObjcMethodDeclarationRewriter *methodDeclarationRewriter;
    __block XMASObjcMethodDeclarationStringWriter *methodDeclarationStringWriter;
    __block id<XMASChangeMethodSignatureControllerDelegate> delegate;

    beforeEach(^{
        alerter = nice_fake_for([XMASAlert class]);

        window = nice_fake_for([NSWindow class]);

        windowProvider = nice_fake_for([XMASWindowProvider class]);
        windowProvider stub_method(@selector(provideInstance)).and_return(window);

        delegate = nice_fake_for(@protocol(XMASChangeMethodSignatureControllerDelegate));

        methodOccurrencesRepository = nice_fake_for([XMASMethodOccurrencesRepository class]);
        callExpressionRewriter = nice_fake_for([XMASObjcCallExpressionRewriter class]);
        methodDeclarationRewriter = nice_fake_for([XMASObjcMethodDeclarationRewriter class]);
        methodDeclarationStringWriter = nice_fake_for([XMASObjcMethodDeclarationStringWriter class]);
        methodDeclarationStringWriter stub_method(@selector(formatInstanceMethodDeclaration:))
            .and_return(@"- (obviously)notTheCorrect:(SEL)butJustAPlaceholder");

        subject = [[XMASChangeMethodSignatureController alloc] initWithWindowProvider:windowProvider
                                                                             delegate:delegate
                                                                              alerter:alerter
                                                              methodOccurrencesRepository:methodOccurrencesRepository
                                                               callExpressionRewriter:callExpressionRewriter
                                                        methodDeclarationStringWriter:methodDeclarationStringWriter
                                                            methodDeclarationRewriter:methodDeclarationRewriter];
    });

    void(^itShouldResizeitsTableView)() = ^void(){
        it(@"should resize its tableview to match the number of rows the selector has", ^{
            CGFloat headerHeight = CGRectGetHeight(subject.tableView.headerView.frame) + 1;
            CGFloat rowHeight = subject.tableView.rowHeight;
            CGFloat tableviewHeight = headerHeight + ([subject numberOfRowsInTableView:subject.tableView]) * (rowHeight + 5);
            subject.tableviewHeight.constant should equal(tableviewHeight);
        });
    };

    describe(@"-refactorMethod:inFile:", ^{
        __block XMASObjcMethodDeclaration *method;
        __block NSString *filepath;

        beforeEach(^{
            methodDeclarationStringWriter stub_method(@selector(formatInstanceMethodDeclaration:))
                .again()
                .and_return(@"- (whoops)iAccidentallyAllTheTests");

            XMASObjcMethodDeclarationParameter *firstParam = nice_fake_for([XMASObjcMethodDeclarationParameter class]);
            firstParam stub_method(@selector(type)).and_return(@"id");
            firstParam stub_method(@selector(localName)).and_return(@"something");

            XMASObjcMethodDeclarationParameter *secondParam = nice_fake_for([XMASObjcMethodDeclarationParameter class]);
            secondParam stub_method(@selector(type)).and_return(@"NSString *");
            secondParam stub_method(@selector(localName)).and_return(@"thisThingy");

            XMASObjcMethodDeclarationParameter *thirdParam = nice_fake_for([XMASObjcMethodDeclarationParameter class]);
            thirdParam stub_method(@selector(type)).and_return(@"NSInteger");
            thirdParam stub_method(@selector(localName)).and_return(@"_thatThing");

            NSArray *components = @[@"initWithSomething", @"this", @"andThat"];
            NSArray *parameters = @[firstParam, secondParam, thirdParam];
            method = [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:components
                                                               parameters:parameters
                                                               returnType:@"instancetype"
                                                                    range:NSMakeRange(0, 0)
                                                                        lineNumber:0
                                                                      columnNumber:0];

            filepath = @"/tmp/imagine.all.the.people";
            [subject refactorMethod:method inFile:filepath];
        });

        itShouldResizeitsTableView();

        it(@"should not have any spacing between the rows in the tableview", ^{
            subject.tableView.intercellSpacing.height should equal(0);
        });

        it(@"should ask for a window from its window provider", ^{
            windowProvider should have_received(@selector(provideInstance));
        });

        it(@"should not release the window when it is closed", ^{
            window should have_received(@selector(setReleasedWhenClosed:)).with(NO);
        });

        describe(@"as a <NSTextFieldDelegate>", ^{
            beforeEach(^{
                subject.view should_not be_nil;

                NSTextField *firstTextField = (id)[subject.tableView viewAtColumn:0 row:0 makeIfNecessary:YES];
                firstTextField.stringValue = @"whoops";

                NSNotification *notification = fake_for([NSNotification class]);
                notification stub_method(@selector(object)).and_return(firstTextField);

                methodDeclarationStringWriter stub_method(@selector(formatInstanceMethodDeclaration:))
                    .again()
                    .and_return(@"- (preview)goesHere");

                [subject controlTextDidChange:notification];
            });

            it(@"should update the preview as the user types", ^{
                subject.previewTextField.stringValue should equal(@"- (preview)goesHere");
            });

            it(@"should collaborate with its method declaration string writer", ^{
                methodDeclarationStringWriter should have_received(@selector(formatInstanceMethodDeclaration:))
                    .with(subject.method);
            });
        });

        describe(@"as a <NSWindowDelegate>", ^{
            it(@"should be the delegate of its window", ^{
                window should have_received(@selector(setDelegate:)).with(subject);
            });

            describe(@"when the window closes", ^{
                beforeEach(^{
                    [subject windowWillClose:nice_fake_for([NSNotification class])];
                });

                it(@"should notify its delegate that it will disappear", ^{
                    delegate should have_received(@selector(controllerWillDisappear:)).with(subject);
                });
            });
        });

        describe(@"when the refactor action is invoked again", ^{
            beforeEach(^{
                [windowProvider reset_sent_messages];
                [subject refactorMethod:method inFile:filepath];
            });

            it(@"should not ask for another window", ^{
                windowProvider should_not have_received(@selector(provideInstance));
            });
        });

        describe(@"after the view loads", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });

            it(@"should make its window key and visible", ^{
                window should have_received(@selector(makeKeyAndOrderFront:)).with(NSApp);
            });

            it(@"should set its view on the window", ^{
                window should have_received(@selector(setContentView:)).with(subject.view);
            });

            it(@"should display the return type for the user to see", ^{
                subject.returnTypeTextField.stringValue should equal(@"instancetype");
            });

            describe(@"the preview area", ^{
                it(@"should initially include the original method", ^{
                    subject.previewTextField.stringValue should equal(@"- (whoops)iAccidentallyAllTheTests");
                });

                it(@"should collaborate with its method declaration string writer", ^{
                    methodDeclarationStringWriter should have_received(@selector(formatInstanceMethodDeclaration:))
                        .with(subject.method);
                });
            });

            describe(@"its tableview", ^{
                it(@"should have a datasource and delegate", ^{
                    subject.tableView.delegate should be_same_instance_as(subject);
                    subject.tableView.dataSource should be_same_instance_as(subject);
                });

                it(@"should not allow multiple selection", ^{
                    subject.tableView.allowsMultipleSelection should be_falsy;
                });

                it(@"should have one row for each segment of the selector", ^{
                    subject.tableView.numberOfRows should equal(3);
                });

                it(@"should have three columns", ^{
                    subject.tableView.numberOfColumns should equal(3);
                });

                describe(@"clicking the 'add component' button", ^{
                    it(@"should be achievable by typing a key", ^{
                        subject.addComponentButton.keyEquivalent should equal(@"a");
                    });

                    context(@"when no rows are selected", ^{
                        beforeEach(^{
                            [subject.addComponentButton performClick:nil];
                        });

                        it(@"should add another row to the tableview", ^{
                            subject.tableView.numberOfRows should equal(4);
                        });

                        // this works in production, but doesn't seem to work here
                        // Things I've tried -> spinning the run loop
                        xit(@"should move focus to the selector textfield for the fourth row", ^{
                            NSTextField *textField = (id)[subject.tableView viewAtColumn:0 row:3 makeIfNecessary:NO];
                            textField should be_instance_of([NSTextField class]);
                            window.firstResponder should be_same_instance_as(textField);
                        });

                        it(@"should use the correct font for the textfield", ^{
                            NSTextField *textField = (id)[subject.tableView viewAtColumn:0 row:3 makeIfNecessary:YES];
                            textField.font should equal([NSFont fontWithName:@"Menlo" size:13.0f]);
                        });
                    });

                    context(@"when a row is selected", ^{
                        beforeEach(^{
                            NSIndexSet *firstRowIndex = [[NSIndexSet alloc] initWithIndex:0];
                            [subject.tableView selectRowIndexes:firstRowIndex byExtendingSelection:NO];

                            methodDeclarationStringWriter stub_method(@selector(formatInstanceMethodDeclaration:))
                                .again()
                                .and_return(@"- (welp)addedMoarComponents");


                            [subject.addComponentButton performClick:nil];
                        });

                        it(@"should add another row to the tableview", ^{
                            subject.tableView.numberOfRows should equal(4);
                        });


                        itShouldResizeitsTableView();

                        it(@"should insert the new row between the first and second rows", ^{
                            NSTextField *firstSelector = (id)[subject.tableView viewAtColumn:0 row:0 makeIfNecessary:YES];
                            firstSelector.stringValue should equal(@"initWithSomething");

                            NSTextField *secondSelector = (id)[subject.tableView viewAtColumn:0 row:1 makeIfNecessary:YES];
                            secondSelector.stringValue should equal(@"");

                            NSTextField *thirdSelector = (id)[subject.tableView viewAtColumn:0 row:2 makeIfNecessary:YES];
                            thirdSelector.stringValue should equal(@"this");
                        });

                        it(@"should update the preview", ^{
                            subject.previewTextField.stringValue should equal(@"- (welp)addedMoarComponents");
                        });

                        it(@"should collaborate with its method declaration string writer", ^{
                            methodDeclarationStringWriter should have_received(@selector(formatInstanceMethodDeclaration:))
                                .with(subject.method);
                        });
                    });
                });

                describe(@"the raise component button", ^{
                    context(@"before a row is selected", ^{
                        it(@"should be disabled", ^{
                            subject.raiseComponentButton.enabled should be_falsy;
                        });

                        context(@"after a row that can be raised is selected", ^{
                            beforeEach(^{
                                NSIndexSet *lastRow = [[NSIndexSet alloc] initWithIndex:2];
                                [subject.tableView selectRowIndexes:lastRow byExtendingSelection:NO];
                            });

                            it(@"should enable the button", ^{
                                subject.raiseComponentButton.enabled should be_truthy;
                            });

                            describe(@"and the button is tapped", ^{
                                __block XMASObjcMethodDeclaration *spiedMethod;

                                beforeEach(^{
                                    spy_on(subject.method);
                                    spiedMethod = subject.method;

                                    spy_on(subject.tableView);

                                    methodDeclarationStringWriter stub_method(@selector(formatInstanceMethodDeclaration:))
                                        .again()
                                        .and_return(@"- (awwYISS)raisingAllTheComponents");

                                    [subject.raiseComponentButton performClick:nil];
                                });

                                it(@"should swap the selected component with the one below it", ^{
                                    spiedMethod should have_received(@selector(swapComponentAtIndex:withComponentAtIndex:))
                                        .with(2, 1);
                                });

                                it(@"should tell its tableview to reload, so it can become aware of this change", ^{
                                    subject.tableView should have_received(@selector(reloadData));
                                });

                                it(@"should move the selection to the upper row", ^{
                                    subject.tableView.selectedRow should equal(1);
                                });

                                it(@"should display a preview original method", ^{
                                    subject.previewTextField.stringValue should equal(@"- (awwYISS)raisingAllTheComponents");
                                });

                                it(@"should collaborate with its method declaration string writer", ^{
                                    methodDeclarationStringWriter should have_received(@selector(formatInstanceMethodDeclaration:))
                                    .with(subject.method);
                                });
                            });
                        });

                        context(@"when the first row is selected", ^{
                            beforeEach(^{
                                NSIndexSet *lastRow = [[NSIndexSet alloc] initWithIndex:0];
                                [subject.tableView selectRowIndexes:lastRow byExtendingSelection:NO];
                            });

                            it(@"should disable the button", ^{
                                subject.raiseComponentButton.enabled should be_falsy;
                            });
                        });
                    });
                });

                describe(@"the lower component button", ^{
                    context(@"before a row is selected", ^{
                        it(@"should be disabled", ^{
                            subject.lowerComponentButton.enabled should be_falsy;
                        });

                        context(@"after a row that can be lowered is selected", ^{
                            beforeEach(^{
                                NSIndexSet *firstRow = [[NSIndexSet alloc] initWithIndex:0];
                                [subject.tableView selectRowIndexes:firstRow byExtendingSelection:NO];
                            });

                            it(@"should enable the button", ^{
                                subject.lowerComponentButton.enabled should be_truthy;
                            });

                            describe(@"and the button is tapped", ^{
                                __block XMASObjcMethodDeclaration *spiedMethod;

                                beforeEach(^{
                                    spy_on(subject.method);
                                    spiedMethod = subject.method;

                                    spy_on(subject.tableView);

                                    methodDeclarationStringWriter stub_method(@selector(formatInstanceMethodDeclaration:))
                                        .again()
                                        .and_return(@"- (awwNAWW)loweringAllTheComponents");

                                    [subject.lowerComponentButton performClick:nil];
                                });

                                it(@"should swap the selected component with the one below it", ^{
                                    spiedMethod should have_received(@selector(swapComponentAtIndex:withComponentAtIndex:))
                                        .with(0, 1);
                                });

                                it(@"should tell its tableview to reload, so it can become aware of this change", ^{
                                    subject.tableView should have_received(@selector(reloadData));
                                });

                                it(@"should move the selection to the lower row", ^{
                                    subject.tableView.selectedRow should equal(1);
                                });

                                it(@"should update the preview", ^{
                                    subject.previewTextField.stringValue should equal(@"- (awwNAWW)loweringAllTheComponents");
                                });

                                it(@"should collaborate with its method declaration string writer", ^{
                                    methodDeclarationStringWriter should have_received(@selector(formatInstanceMethodDeclaration:))
                                        .with(subject.method);
                                });
                            });
                        });

                        context(@"when the last row is selected", ^{
                            beforeEach(^{
                                NSIndexSet *lastRow = [[NSIndexSet alloc] initWithIndex:2];
                                [subject.tableView selectRowIndexes:lastRow byExtendingSelection:NO];
                            });

                            it(@"should disable the button", ^{
                                subject.lowerComponentButton.enabled should be_falsy;
                            });
                        });
                    });
                });

                describe(@"the refactor button", ^{
                    it(@"should be the default button", ^{
                        subject.refactorButton.bezelStyle should equal(NSRoundedBezelStyle);
                        subject.refactorButton.keyEquivalent should equal(@"\r");
                    });
                });

                describe(@"clicking the 'remove component' button", ^{
                    context(@"when a row is selected", ^{
                        beforeEach(^{
                            NSIndexSet *secondRowIndex = [[NSIndexSet alloc] initWithIndex:1];
                            [subject.tableView selectRowIndexes:secondRowIndex byExtendingSelection:NO];

                            methodDeclarationStringWriter stub_method(@selector(formatInstanceMethodDeclaration:))
                                .again()
                                .and_return(@"- (hrm)removedSomeThings");

                            [subject.removeComponentButton performClick:nil];
                        });

                        it(@"should only have two rows", ^{
                            subject.tableView.numberOfRows should equal(2);
                        });

                        it(@"should only have removed the row at index 1", ^{
                            NSTextField *firstSelector = (id)[subject.tableView viewAtColumn:0 row:0 makeIfNecessary:YES];
                            firstSelector.stringValue should equal(@"initWithSomething");

                            NSTextField *secondSelector = (id)[subject.tableView viewAtColumn:0 row:1 makeIfNecessary:YES];
                            secondSelector.stringValue should equal(@"andThat");
                        });

                        itShouldResizeitsTableView();

                        it(@"should update the preview", ^{
                            subject.previewTextField.stringValue should equal(@"- (hrm)removedSomeThings");
                        });

                        it(@"should collaborate with its method declaration string writer", ^{
                            methodDeclarationStringWriter should have_received(@selector(formatInstanceMethodDeclaration:))
                                .with(subject.method);
                        });
                    });

                    context(@"when no row is selected", ^{
                        it(@"should not crash", ^{
                            ^{ [subject.removeComponentButton performClick:nil]; } should_not raise_exception;
                        });
                    });
                });

                describe(@"the first row", ^{
                    it(@"should have the correct cell contents", ^{
                        NSTableColumn *firstColumn = subject.tableView.tableColumns.firstObject;
                        NSTextField *firstRowFirstColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                                  viewForTableColumn:firstColumn
                                                                                                 row:0];
                        firstRowFirstColumn.stringValue should equal(@"initWithSomething");

                        NSTableColumn *secondColumn = subject.tableView.tableColumns[1];
                        NSTextField *firstRowSecondColumn = (id)[subject.tableView.delegate tableView:subject.tableView 
                                                                                   viewForTableColumn:secondColumn
                                                                                                  row:0];
                        firstRowSecondColumn.stringValue should equal(@"id");

                        NSTableColumn *thirdColumn = subject.tableView.tableColumns[2];
                        NSTextField *firstRowThirdColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                                  viewForTableColumn:thirdColumn
                                                                                                 row:0];
                        firstRowThirdColumn.stringValue should equal(@"something");
                    });
                });

                describe(@"the second row", ^{
                    it(@"should have the correct cell contents", ^{
                        NSTableColumn *firstColumn = subject.tableView.tableColumns.firstObject;
                        NSTextField *secondRowFirstColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                                   viewForTableColumn:firstColumn
                                                                                                  row:1];
                        secondRowFirstColumn.stringValue should equal(@"this");

                        NSTableColumn *secondColumn = subject.tableView.tableColumns[1];
                        NSTextField *secondRowSecondColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                                    viewForTableColumn:secondColumn
                                                                                                   row:1];
                        secondRowSecondColumn.stringValue should equal(@"NSString *");

                        NSTableColumn *thirdColumn = subject.tableView.tableColumns[2];
                        NSTextField *secondRowThirdColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                                   viewForTableColumn:thirdColumn
                                                                                                  row:1];
                        secondRowThirdColumn.stringValue should equal(@"thisThingy");
                    });
                });

                describe(@"the third row", ^{
                    it(@"should have the correct cell contents", ^{
                        NSTableColumn *firstColumn = subject.tableView.tableColumns.firstObject;
                        NSTextField *thirdRowFirstColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                                  viewForTableColumn:firstColumn
                                                                                                 row:2];
                        thirdRowFirstColumn.stringValue should equal(@"andThat");

                        NSTableColumn *secondColumn = subject.tableView.tableColumns[1];
                        NSTextField *thirdRowSecondColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                                   viewForTableColumn:secondColumn
                                                                                                  row:2];
                        thirdRowSecondColumn.stringValue should equal(@"NSInteger");

                        NSTableColumn *thirdColumn = subject.tableView.tableColumns[2];
                        NSTextField *thirdRowThirdColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                                  viewForTableColumn:thirdColumn
                                                                                                 row:2];
                        thirdRowThirdColumn.stringValue should equal(@"_thatThing");
                    });
                });

                describe(@"the columns", ^{
                    __block NSArray *columns;
                    beforeEach(^{
                        columns = subject.tableView.tableColumns;
                    });

                    it(@"should have the correct headers", ^{
                        NSArray *headers = [columns valueForKeyPath:@"headerCell.stringValue"];
                        headers should equal(@[@"Selector Part", @"Type", @"Name"]);
                    });
                });
            });

            it(@"should make the window key and visible", ^{
                window should have_received(@selector(makeKeyAndOrderFront:)).with(NSApp);
            });

            it(@"should set its view on the window", ^{
                window should have_received(@selector(setContentView:)).with(subject.view);
            });
        });
    });

    describe(@"refactoring a method with no parameters", ^{
        __block XMASObjcMethodDeclaration *method;
        __block NSString *filepath;

        beforeEach(^{
            NSArray *components = @[@"viewDidLoad"];
            method = [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:components
                                                                        parameters:@[]
                                                                        returnType:@"void"
                                                                             range:NSMakeRange(0, 0)
                                                                        lineNumber:0
                                                                      columnNumber:0];

            filepath = @"/tmp/imagine.all.the.people";
            [subject refactorMethod:method inFile:filepath];
        });

        itShouldResizeitsTableView();

        describe(@"its tableview", ^{
            it(@"should have a datasource and delegate", ^{
                subject.tableView.delegate should be_same_instance_as(subject);
                subject.tableView.dataSource should be_same_instance_as(subject);
            });

            it(@"should have one row", ^{
                subject.tableView.numberOfRows should equal(1);
            });

            it(@"should have three columns", ^{
                subject.tableView.numberOfColumns should equal(3);
            });

            describe(@"the first row", ^{
                it(@"should have the correct cell contents", ^{
                    NSTableColumn *firstColumn = subject.tableView.tableColumns.firstObject;
                    NSTextField *firstRowFirstColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                              viewForTableColumn:firstColumn
                                                                                             row:0];
                    firstRowFirstColumn.stringValue should equal(@"viewDidLoad");

                    NSTableColumn *secondColumn = subject.tableView.tableColumns[1];
                    NSTextField *firstRowSecondColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                               viewForTableColumn:secondColumn
                                                                                              row:0];
                    firstRowSecondColumn.stringValue should equal(@"");

                    NSTableColumn *thirdColumn = subject.tableView.tableColumns[2];
                    NSTextField *firstRowThirdColumn = (id)[subject.tableView.delegate tableView:subject.tableView
                                                                              viewForTableColumn:thirdColumn
                                                                                             row:0];
                    firstRowThirdColumn.stringValue should equal(@"");
                });
            });
        });
    });

    describe(@"the cancel and refactor buttons", ^{
        __block XMASObjcMethodDeclaration *methodToRefactor;

        beforeEach(^{
            methodToRefactor = fake_for([XMASObjcMethodDeclaration class]);
            methodToRefactor stub_method(@selector(selectorString)).and_return(@"method:to:refactor:");
            methodToRefactor stub_method(@selector(returnType)).and_return(@"something");
        });

        describe(@"clicking the cancel button", ^{
            beforeEach(^{
                subject.view should_not be_nil;
                [subject refactorMethod:methodToRefactor inFile:nil];

                [subject.cancelButton performClick:nil];
            });

            it(@"should close the window", ^{
                window should have_received(@selector(close));
            });
        });

        describe(@"tapping the refactor button", ^{
            context(@"when the file being refactored is a .h file", ^{
                __block NSString *filePathToRewrite;
                __block NSArray *matchingForwardDeclarations;

                beforeEach(^{
                    filePathToRewrite = @"/just/pretend/this/is/a/valid/file_path.h";

                    matchingForwardDeclarations = @[@"just", @"a", @"test"];
                    methodOccurrencesRepository stub_method(@selector(forwardDeclarationsOfMethod:))
                        .with(methodToRefactor)
                        .and_return(matchingForwardDeclarations);

                    methodOccurrencesRepository stub_method(@selector(callSitesOfCurrentlySelectedMethod))
                        .and_return(@[@"something", @"goes", @"here"]);

                    subject.view should_not be_nil;
                    [subject refactorMethod:methodToRefactor inFile:filePathToRewrite];

                    [subject.refactorButton performClick:nil];
                });

                it(@"should also attempt to rewrite the .m file", ^{
                    methodDeclarationRewriter should have_received(@selector(changeMethodDeclaration:toNewMethod:inFile:))
                    .with(methodToRefactor, subject.method, @"/just/pretend/this/is/a/valid/file_path.m");
                });
            });

            context(@"when the file being edited is a .m file", ^{
                __block NSString *filePathToRewrite;
                __block NSArray *matchingForwardDeclarations;

                beforeEach(^{
                    filePathToRewrite = @"/just/pretend/this/is/a/valid/file_path.m";

                    matchingForwardDeclarations = @[@"just", @"a", @"test"];
                    methodOccurrencesRepository stub_method(@selector(forwardDeclarationsOfMethod:))
                        .with(methodToRefactor)
                        .and_return(matchingForwardDeclarations);

                    methodOccurrencesRepository stub_method(@selector(callSitesOfCurrentlySelectedMethod))
                        .and_return(@[@"something", @"goes", @"here"]);

                    subject.view should_not be_nil;
                    [subject refactorMethod:methodToRefactor inFile:filePathToRewrite];

                    [subject.refactorButton performClick:nil];
                });

                it(@"should ask its call expression rewriter to change each call site", ^{
                    callExpressionRewriter should have_received(@selector(changeCallsite:fromMethod:toNewMethod:))
                        .with(@"something", methodToRefactor, subject.method);
                    callExpressionRewriter should have_received(@selector(changeCallsite:fromMethod:toNewMethod:))
                        .with(@"goes", methodToRefactor, subject.method);
                    callExpressionRewriter should have_received(@selector(changeCallsite:fromMethod:toNewMethod:))
                        .with(@"here", methodToRefactor, subject.method);
                });

                it(@"should ask its method declaration rewriter to change the method declaration", ^{
                    methodDeclarationRewriter should have_received(@selector(changeMethodDeclaration:toNewMethod:inFile:))
                        .with(methodToRefactor, subject.method, filePathToRewrite);
                });

                it(@"should find matching forward declarations of the method", ^{
                    methodOccurrencesRepository should have_received(@selector(forwardDeclarationsOfMethod:))
                        .with(methodToRefactor);
                });

                it(@"should rewrite each forward declaration of the method", ^{
                    methodDeclarationRewriter should have_received(@selector(changeMethodDeclarationForSymbol:toMethod:))
                        .with(@"just", subject.method);
                    methodDeclarationRewriter should have_received(@selector(changeMethodDeclarationForSymbol:toMethod:))
                        .with(@"a", subject.method);
                    methodDeclarationRewriter should have_received(@selector(changeMethodDeclarationForSymbol:toMethod:))
                        .with(@"test", subject.method);
                });

                it(@"should close the window", ^{
                    window should have_received(@selector(close));
                });
            });

            context(@"when something goes awry with the indexed symbol repository and an exception would be raised", ^{
                beforeEach(^{
                    methodOccurrencesRepository stub_method(@selector(callSitesOfCurrentlySelectedMethod))
                        .and_raise_exception();

                    subject.view should_not be_nil;
                    [subject refactorMethod:methodToRefactor inFile:nil];
                });

                it(@"should catch the exception and not allow xcode to crash", ^{
                    ^{ [subject.refactorButton performClick:nil]; } should_not raise_exception();
                });

                it(@"should log the exception", ^{
                    [subject.refactorButton performClick:nil];
                    alerter should have_received(@selector(flashComfortingMessageForException:));
                });
            });

            context(@"when something goes awry while rewriting the callsites and an exception would be raised", ^{
                beforeEach(^{
                    methodOccurrencesRepository stub_method(@selector(callSitesOfCurrentlySelectedMethod))
                        .and_return(@[@"something", @"goes", @"here"]);

                    callExpressionRewriter stub_method(@selector(changeCallsite:fromMethod:toNewMethod:))
                        .and_raise_exception();

                    subject.view should_not be_nil;
                    [subject refactorMethod:methodToRefactor inFile:nil];
                });

                it(@"should catch the exception and not allow xcode to crash", ^{
                    ^{ [subject.refactorButton performClick:nil]; } should_not raise_exception();
                });

                it(@"should log the exception", ^{
                    [subject.refactorButton performClick:nil];
                    alerter should have_received(@selector(flashComfortingMessageForException:));
                });
            });
        });
    });
});

SPEC_END
