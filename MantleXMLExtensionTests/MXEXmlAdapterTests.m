//
//  MXEXmlAdapterTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETSampleModel.h"
#import "MXETTypeModel.h"
#import "MXETUsersResponse.h"
#import "MXEXmlNode.h"

@interface MXEXmlAdapter () <NSXMLParserDelegate>
@property (nonatomic, nonnull, strong) NSMutableArray<MXEXmlNode*>* xmlParseStack;
@property (nonatomic, nullable, strong) NSError* parseError;
+ (NSStringEncoding)xmlDeclarationToEncoding:(NSString*)xmlDeclaration;
@end

QuickSpecBegin(MXEXmlAdapterTests)
{
    describe(@"Initializer validation", ^{
        __block id mock = nil;

        beforeEach(^{
            mock = OCMClassMock(MXETSampleModel.class);
        });

        afterEach(^{
            [mock stopMocking];
        });

        it(@"xmlKeyPathsByPropertyKey included properties isn't found in model", ^{
            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{ @"notFound" : @"a" });
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());
        });
        it(@"xmlKeyPathsByPropertyKey is array", ^{
            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{ @"a" : @[] });
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());
        });
        it(@"xmlKeyPathsByPropertyKey is valid", ^{
            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{ @"a" : @"hoge.fuga" });
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{ @"a" : @"a" });
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn((@{ @"a" : MXEXmlAttribute(@"hoge", @"fuga") }));
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn((@{ @"a" : MXEXmlArray(@"hoge", @"fuga") }));
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));
        });
    });

    describe(@"serialize / deserialize", ^{

        NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                           @"<response status=\"ok\">"
                           @"<summary>"
                           @"<count>2</count>"
                           @"</summary>"
                           @"<user first_name=\"Ai\" last_name=\"Asada\">"
                           @"<age>25</age>"
                           @"<sex>Woman</sex>"
                           @"</user>"
                           @"<user first_name=\"Ikuo\" last_name=\"Ikeda\">"
                           @"<age>32</age>"
                           @"<sex>Man</sex>"
                           @"<parent first_name=\"Umeo\" last_name=\"Ueda\">"
                           @"<age>50</age>"
                           @"<sex>Man</sex>"
                           @"</parent>"
                           @"<child first_name=\"Eiko\" last_name=\"Endo\">"
                           @"<age>10</age>"
                           @"<sex>Woman</sex>"
                           @"</child>"
                           @"</user>"
                           @"</response>";
        NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

        it(@"sample (1)", ^{
            MXETUsersResponse* response = [MXEXmlAdapter modelOfClass:MXETUsersResponse.class
                                                          fromXmlData:xmlData
                                                                error:nil];
            expect(response.status).to(equal(@"ok"));
            expect(response.userCount).to(equal(2));
            expect(response.users.count).to(equal(2));

            expect(response.users[0].firstName).to(equal(@"Ai"));
            expect(response.users[0].lastName).to(equal(@"Asada"));
            expect(response.users[0].age).to(equal(25));
            expect(response.users[0].sex == MXETWoman).to(equal(YES));
            expect(response.users[0].parent).to(beNil());
            expect(response.users[0].child).to(beNil());

            expect(response.users[1].firstName).to(equal(@"Ikuo"));
            expect(response.users[1].lastName).to(equal(@"Ikeda"));
            expect(response.users[1].age).to(equal(32));
            expect(response.users[1].sex == MXETMan).to(equal(YES));
            expect(response.users[1].parent).notTo(beNil());
            expect(response.users[1].child).notTo(beNil());

            expect(response.users[1].parent.firstName).to(equal("Umeo"));
            expect(response.users[1].parent.lastName).to(equal("Ueda"));
            expect(response.users[1].parent.age).to(equal(50));
            expect(response.users[1].parent.sex == MXETMan).to(equal(YES));
            expect(response.users[1].parent.parent).to(beNil());
            expect(response.users[1].parent.child).to(beNil());

            expect(response.users[1].child.firstName).to(equal("Eiko"));
            expect(response.users[1].child.lastName).to(equal("Endo"));
            expect(response.users[1].child.age).to(equal(10));
            expect(response.users[1].child.sex == MXETWoman).to(equal(YES));
            expect(response.users[1].child.parent).to(beNil());
            expect(response.users[1].child.child).to(beNil());

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(xmlData));
        });
    });

    describe(@"-boolTransformer:", ^{

        NSString* expectedXmlStrTrue = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"true\" double=\"0\" float=\"0\" int=\"0\" />";
        NSData* expectedXmlDataTrue = [expectedXmlStrTrue dataUsingEncoding:NSUTF8StringEncoding];

        NSString* expectedXmlStrFalse = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                        @"<response bool=\"false\" double=\"0\" float=\"0\" int=\"0\" />";
        NSData* expectedXmlDataFalse = [expectedXmlStrFalse dataUsingEncoding:NSUTF8StringEncoding];

        it(@"integer to bool", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response bool=\"1\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.boolNum).to(equal(YES));

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlDataTrue));
        });

        it(@"true string to bool", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response bool=\"true\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.boolNum).to(equal(YES));

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlDataTrue));
        });

        it(@"false string to bool", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response bool=\"false\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.boolNum).to(equal(NO));

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlDataFalse));
        });

        it(@"0 integer to bool", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response bool=\"0\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.boolNum).to(equal(NO));

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlDataFalse));
        });
    });

    describe(@"-numberTransformer:", ^{
        it(@"integer", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response int=\"20\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.intNum).to(equal(20));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"0\" float=\"0\" int=\"20\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"plus integer", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response int=\"+20\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.intNum).to(equal(20));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"0\" float=\"0\" int=\"20\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"minus integer", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response int=\"-20\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.intNum).to(equal(-20));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"0\" float=\"0\" int=\"-20\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"zero integer", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response int=\"0\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.intNum).to(equal(0));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"0\" float=\"0\" int=\"0\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"float", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response float=\"20.25f\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.floatNum).to(equal(20.25));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"0\" float=\"20.25\" int=\"0\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"plus float", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response float=\"+20.25f\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.floatNum).to(equal(20.25));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"0\" float=\"20.25\" int=\"0\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"minus float", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response float=\"-20.25f\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.floatNum).to(equal(-20.25));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"0\" float=\"-20.25\" int=\"0\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"zero float", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response float=\"0.0f\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.floatNum).to(equal(0));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"0\" float=\"0\" int=\"0\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"double", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response double=\"20.25f\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.doubleNum).to(equal(20.25));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"20.25\" float=\"0\" int=\"0\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"plus double", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response double=\"+20.25f\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.doubleNum).to(equal(20.25));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"20.25\" float=\"0\" int=\"0\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"minus double", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response double=\"-20.25f\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.doubleNum).to(equal(-20.25));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"-20.25\" float=\"0\" int=\"0\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });

        it(@"zero double", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response double=\"0.0f\" />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            MXETTypeModel* response = [MXEXmlAdapter modelOfClass:MXETTypeModel.class
                                                      fromXmlData:xmlData
                                                            error:nil];

            expect(response.doubleNum).to(equal(0));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response bool=\"false\" double=\"0\" float=\"0\" int=\"0\" />";
            NSData* expectedXmlData = [expectedXmlStr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(expectedXmlData));
        });
    });

#pragma mark - Private Method Tests

    describe(@"+xmlDeclarationToEncoding:", ^{

        it(@"utf8", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
            expect([MXEXmlAdapter xmlDeclarationToEncoding:xmlDeclaration]).to(equal(NSUTF8StringEncoding));
        });

        it(@"utf16", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"UTF-16\"?>";
            expect([MXEXmlAdapter xmlDeclarationToEncoding:xmlDeclaration]).to(equal(NSUTF16StringEncoding));
        });

        it(@"shift jis", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"Shift_JIS\"?>";
            expect([MXEXmlAdapter xmlDeclarationToEncoding:xmlDeclaration]).to(equal(NSShiftJISStringEncoding));
        });

        it(@"euc-jp", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"EUC-JP\"?>";
            expect([MXEXmlAdapter xmlDeclarationToEncoding:xmlDeclaration]).to(equal(NSJapaneseEUCStringEncoding));
        });

        it(@"lower case", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"euc-jp\"?>";
            expect([MXEXmlAdapter xmlDeclarationToEncoding:xmlDeclaration]).to(equal(NSJapaneseEUCStringEncoding));
        });
    });

    describe(@"XMLParser", ^{
        NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                           @"<response status=\"OK\">"
                           @"  <user>  <id>"
                           @"                1"
                           @"  </id>      </user>"
                           @"  <user>  <id>2</id>  </user>"
                           @"</response>";
        __block id mock = nil;

        beforeEach(^{
            mock = OCMClassMock(MXETSampleModel.class);
        });

        afterEach(^{
            [mock stopMocking];
        });

        it(@"Ignore character string when child node and character string are mixed", ^{
            OCMStub([mock xmlRootElementName]).andReturn(@"response");

            NSXMLParser* parser = [[NSXMLParser alloc] initWithData:[xmlStr dataUsingEncoding:NSUTF8StringEncoding]];
            MXEXmlAdapter* adapter = [[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class];
            parser.delegate = adapter;
            MXEXmlNode* expectedObj = [[MXEXmlNode alloc] initWithElementName:@"response"];
            expectedObj.attributes = @{ @"status" : @"OK" };

            MXEXmlNode* user1 = [[MXEXmlNode alloc] initWithElementName:@"user"];
            MXEXmlNode* user2 = [[MXEXmlNode alloc] initWithElementName:@"user"];
            MXEXmlNode* userId1 = [[MXEXmlNode alloc] initWithElementName:@"id"];
            MXEXmlNode* userId2 = [[MXEXmlNode alloc] initWithElementName:@"id"];
            userId1.children = @"1";
            user1.children = @[ userId1 ];

            userId2.children = @"2";
            user2.children = @[ userId2 ];
            expectedObj.children = @[ user1, user2 ];

            expect([parser parse]).to(equal(YES));
            expect(adapter.xmlParseStack.count).to(equal(1));
            expect([adapter.xmlParseStack lastObject]).to(equal(expectedObj));
        });

        it(@"root element is different", ^{
            OCMStub([mock xmlRootElementName]).andReturn(@"object");

            NSXMLParser* parser = [[NSXMLParser alloc] initWithData:[xmlStr dataUsingEncoding:NSUTF8StringEncoding]];
            MXEXmlAdapter* adapter = [[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class];
            parser.delegate = adapter;

            expect([parser parse]).to(equal(NO));
            expect(parser.parserError.code).to(equal(NSXMLParserDelegateAbortedParseError));
            expect(adapter.parseError).notTo(equal(nil));
        });
    });
}
QuickSpecEnd