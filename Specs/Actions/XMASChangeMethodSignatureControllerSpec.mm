#import <Cedar/Cedar.h>
#import "XMASChangeMethodSignatureController.h"
#import "XMASObjcSelector.h"
#import "XMASObjcSelectorParameter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASChangeMethodSignatureControllerSpec)

describe(@"XMASChangeMethodSignatureController", ^{
    __block NSWindow *window;
    __block XMASChangeMethodSignatureController *subject;

    beforeEach(^{
        window = nice_fake_for([NSWindow class]);
        subject = [[XMASChangeMethodSignatureController alloc] initWithWindow:window];
    });

    describe(@"-refactorMethod:inFile:", ^{
        __block XMASObjcSelector *method;
        __block NSString *filepath;

        beforeEach(^{
            method = nice_fake_for([XMASObjcSelector class]);
            method stub_method(@selector(components)).and_return(@[@"initWith", @"this", @"andThat"]);

            XMASObjcSelectorParameter *firstParam = nice_fake_for([XMASObjcSelectorParameter class]);
            firstParam stub_method(@selector(type)).and_return(@"id");
            firstParam stub_method(@selector(localName)).and_return(@"something");

            XMASObjcSelectorParameter *secondParam = nice_fake_for([XMASObjcSelectorParameter class]);
            secondParam stub_method(@selector(type)).and_return(@"NSString *");
            secondParam stub_method(@selector(localName)).and_return(@"thisThingy");

            XMASObjcSelectorParameter *thirdParam = nice_fake_for([XMASObjcSelectorParameter class]);
            thirdParam stub_method(@selector(type)).and_return(@"NSInteger");
            thirdParam stub_method(@selector(localName)).and_return(@"_thatThing");

            NSArray *parameters = @[firstParam, secondParam, thirdParam];
            method stub_method(@selector(parameters)).and_return(parameters);
            filepath = @"/tmp/imagine.all.the.people";
            [subject refactorMethod:method inFile:filepath];
        });

        describe(@"after the view loads", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });

            describe(@"its tableview", ^{
                it(@"should have a datasource and delegate", ^{
                    subject.tableView.delegate should be_same_instance_as(subject);
                    subject.tableView.dataSource should be_same_instance_as(subject);
                });

                it(@"should have one row for each segment of the selector", ^{
                    subject.tableView.numberOfRows should equal(3);
                });

                it(@"should have three columns", ^{
                    subject.tableView.numberOfColumns should equal(3);
                });

                describe(@"the first row", ^{
                    it(@"should have the correct cell contents", ^{
                        NSTableColumn *firstColumn = subject.tableView.tableColumns.firstObject;
                        NSTextField *firstRowFirstColumn = (id)[subject.tableView.delegate tableView:nil viewForTableColumn:firstColumn row:0];
                        firstRowFirstColumn.stringValue should equal(@"initWith");

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
});

SPEC_END
