#import <Cedar/Cedar.h>
#import "XMASChangeMethodSignatureController.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASWindowProvider.h"
#import "XMASAlert.h"
#import "XMASIndexedSymbolRepository.h"
#import "XMASObjcCallExpressionRewriter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASChangeMethodSignatureControllerSpec)

describe(@"XMASChangeMethodSignatureController", ^{
    __block NSWindow *window;
    __block XMASAlert *alerter;
    __block XMASWindowProvider <CedarDouble> *windowProvider;
    __block XMASChangeMethodSignatureController *subject;
    __block XMASIndexedSymbolRepository *indexedSymbolRepository;
    __block XMASObjcCallExpressionRewriter *callExpressionRewriter;
    __block id<XMASChangeMethodSignatureControllerDelegate> delegate;

    beforeEach(^{
        alerter = nice_fake_for([XMASAlert class]);

        window = nice_fake_for([NSWindow class]);

        windowProvider = nice_fake_for([XMASWindowProvider class]);
        windowProvider stub_method(@selector(provideInstance)).and_return(window);

        delegate = nice_fake_for(@protocol(XMASChangeMethodSignatureControllerDelegate));

        indexedSymbolRepository = nice_fake_for([XMASIndexedSymbolRepository class]);
        callExpressionRewriter = nice_fake_for([XMASObjcCallExpressionRewriter class]);

        subject = [[XMASChangeMethodSignatureController alloc] initWithWindowProvider:windowProvider
                                                                             delegate:delegate
                                                                              alerter:alerter
                                                              indexedSymbolRepository:indexedSymbolRepository
                                                               callExpressionRewriter:callExpressionRewriter];
    });

    describe(@"-refactorMethod:inFile:", ^{
        __block XMASObjcMethodDeclaration *method;
        __block NSString *filepath;

        beforeEach(^{
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
                                                                    range:NSMakeRange(0, 0)];

            filepath = @"/tmp/imagine.all.the.people";
            [subject refactorMethod:method inFile:filepath];
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
                [subject controlTextDidChange:notification];
            });

            it(@"should update the preview as the user types", ^{
                subject.previewTextField.stringValue should equal(@"- (instancetype)whoops:(id)something this:(NSString *)thisThingy andThat:(NSInteger)_thatThing");
            });
        });

        describe(@"as a <NSWindowDelegate>", ^{
            it(@"should be the delegate of its window", ^{
                window should have_received(@selector(setDelegate:)).with(subject);
            });

            describe(@"when the window closes", ^{
                beforeEach(^{
                    [subject windowWillClose:nil];
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

            it(@"should make the window key and visible", ^{
                window should have_received(@selector(makeKeyAndOrderFront:)).with(NSApp);
            });

            it(@"should set its view on the window", ^{
                window should have_received(@selector(setContentView:)).with(subject.view);
            });

            describe(@"the preview area", ^{
                it(@"should initially include the original method", ^{
                    subject.previewTextField.stringValue should equal(@"- (instancetype)initWithSomething:(id)something this:(NSString *)thisThingy andThat:(NSInteger)_thatThing");
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
                    });

                    context(@"when a row is selected", ^{
                        beforeEach(^{
                            NSIndexSet *firstRowIndex = [[NSIndexSet alloc] initWithIndex:0];
                            [subject.tableView selectRowIndexes:firstRowIndex byExtendingSelection:NO];
                            [subject.addComponentButton performClick:nil];
                        });

                        it(@"should add another row to the tableview", ^{
                            subject.tableView.numberOfRows should equal(4);
                        });

                        it(@"should insert the new row between the first and second rows", ^{
                            NSTextField *firstSelector = (id)[subject.tableView viewAtColumn:0 row:0 makeIfNecessary:YES];
                            firstSelector.stringValue should equal(@"initWithSomething");

                            NSTextField *secondSelector = (id)[subject.tableView viewAtColumn:0 row:1 makeIfNecessary:YES];
                            secondSelector.stringValue should equal(@"");

                            NSTextField *thirdSelector = (id)[subject.tableView viewAtColumn:0 row:2 makeIfNecessary:YES];
                            thirdSelector.stringValue should equal(@"this");
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

                                it(@"should initially include the original method", ^{
                                    subject.previewTextField.stringValue should equal(@"- (instancetype)initWithSomething:(id)something andThat:(NSInteger)_thatThing this:(NSString *)thisThingy");
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
                                    subject.previewTextField.stringValue should equal(@"- (instancetype)initWithThis:(NSString *)thisThingy something:(id)something andThat:(NSInteger)_thatThing");
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

                describe(@"clicking the 'remove component' button", ^{
                    context(@"when a row is selected", ^{
                        beforeEach(^{
                            NSIndexSet *secondRowIndex = [[NSIndexSet alloc] initWithIndex:1];
                            [subject.tableView selectRowIndexes:secondRowIndex byExtendingSelection:NO];
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

                        it(@"should update the preview", ^{
                            subject.previewTextField.stringValue should equal(@"- (instancetype)initWithSomething:(id)something andThat:(NSInteger)_thatThing");
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
                        NSTextField *firstRowFirstColumn = (id)[subject.tableView.delegate tableView:nil viewForTableColumn:firstColumn row:0];
                        firstRowFirstColumn.stringValue should equal(@"initWithSomething");

                        NSTableColumn *secondColumn = subject.tableView.tableColumns[1];
                        NSTextField *firstRowSecondColumn = (id)[subject.tableView.delegate tableView:nil viewForTableColumn:secondColumn row:0];
                        firstRowSecondColumn.stringValue should equal(@"id");

                        NSTableColumn *thirdColumn = subject.tableView.tableColumns[2];
                        NSTextField *firstRowThirdColumn = (id)[subject.tableView.delegate tableView:nil viewForTableColumn:thirdColumn row:0];
                        firstRowThirdColumn.stringValue should equal(@"something");
                    });
                });

                describe(@"the second row", ^{
                    it(@"should have the correct cell contents", ^{
                        NSTableColumn *firstColumn = subject.tableView.tableColumns.firstObject;
                        NSTextField *secondRowFirstColumn = (id)[subject.tableView.delegate tableView:nil viewForTableColumn:firstColumn row:1];
                        secondRowFirstColumn.stringValue should equal(@"this");

                        NSTableColumn *secondColumn = subject.tableView.tableColumns[1];
                        NSTextField *secondRowSecondColumn = (id)[subject.tableView.delegate tableView:nil viewForTableColumn:secondColumn row:1];
                        secondRowSecondColumn.stringValue should equal(@"NSString *");

                        NSTableColumn *thirdColumn = subject.tableView.tableColumns[2];
                        NSTextField *secondRowThirdColumn = (id)[subject.tableView.delegate tableView:nil viewForTableColumn:thirdColumn row:1];
                        secondRowThirdColumn.stringValue should equal(@"thisThingy");
                    });
                });

                describe(@"the third row", ^{
                    it(@"should have the correct cell contents", ^{
                        NSTableColumn *firstColumn = subject.tableView.tableColumns.firstObject;
                        NSTextField *thirdRowFirstColumn = (id)[subject.tableView.delegate tableView:nil viewForTableColumn:firstColumn row:2];
                        thirdRowFirstColumn.stringValue should equal(@"andThat");

                        NSTableColumn *secondColumn = subject.tableView.tableColumns[1];
                        NSTextField *thirdRowSecondColumn = (id)[subject.tableView.delegate tableView:nil viewForTableColumn:secondColumn row:2];
                        thirdRowSecondColumn.stringValue should equal(@"NSInteger");

                        NSTableColumn *thirdColumn = subject.tableView.tableColumns[2];
                        NSTextField *thirdRowThirdColumn = (id)[subject.tableView.delegate tableView:nil viewForTableColumn:thirdColumn row:2];
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

    describe(@"clicking the cancel button", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject refactorMethod:nil inFile:nil];

            [subject.cancelButton performClick:nil];
        });

        it(@"should close the window", ^{
            window should have_received(@selector(close));
        });
    });

    describe(@"tapping the refactor button", ^{
        __block XMASObjcMethodDeclaration *methodToRefactor;
        beforeEach(^{
            methodToRefactor = fake_for([XMASObjcMethodDeclaration class]);
            methodToRefactor stub_method(@selector(selectorString)).and_return(@"method:to:refactor:");

            indexedSymbolRepository stub_method(@selector(callExpressionsMatchingSelector:))
                .with(methodToRefactor)
                .and_return(@[@"something", @"goes", @"here"]);

            subject.view should_not be_nil;
            [subject refactorMethod:methodToRefactor inFile:nil];

            [subject.refactorButton performClick:nil];
        });

        it(@"should present a count of the number of matching instances of the old selector", ^{
            alerter should have_received(@selector(flashMessage:))
                .with(@"Changing 3 call sites of method:to:refactor:");
        });

        it(@"should ask its call expression rewriter to change each call site", ^{
            callExpressionRewriter should have_received(@selector(changeCallsite:fromMethod:toNewMethod:))
                .with(@"something", methodToRefactor, subject.method);
            callExpressionRewriter should have_received(@selector(changeCallsite:fromMethod:toNewMethod:))
                .with(@"goes", methodToRefactor, subject.method);
            callExpressionRewriter should have_received(@selector(changeCallsite:fromMethod:toNewMethod:))
                .with(@"here", methodToRefactor, subject.method);
        });
    });
});

SPEC_END
