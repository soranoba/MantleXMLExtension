//
//  MXEXmlAdapterTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETSampleModel.h"
#import "MXEXmlNode.h"

@interface MXEXmlAdapter () <NSXMLParserDelegate>
@property (nonatomic, nonnull, strong) NSMutableArray<MXEXmlNode*>* xmlParseStack;
@property (nonatomic, nullable, strong) NSError* parseError;
+ (NSStringEncoding) xmlDeclarationToEncoding:(NSString*)xmlDeclaration;
@end

QuickSpecBegin(MXEXmlAdapterTests)

describe(@"Initializer validation", ^{
    __block id mock = nil;

    beforeEach(^{
        mock = OCMClassMock(MXETSampleModel.class);
    });

    afterEach(^{
        [mock stopMocking];
    });

    it(@"xmlKeyPathsByPropertyKey included properties isn't found in model", ^{
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"notFound":@"a"});
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());
    });
    it(@"xmlKeyPathsByPropertyKey included empty key fragments", ^{
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":@[]});
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());
    });
    it(@"xmlKeyPathsByPropertyKey included invalid key fragments", ^{
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":[NSObject new]});
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());

        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn((@{@"a":@[@"hoge", [NSObject new]]}));
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());

        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":[NSObject new]});
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());
    });
    it(@"xmlKeyPathsByPropertyKey is valid", ^{
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn((@{@"a":@[@"hoge", @"fuga"]}));
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":@"a"});
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

        MXEXmlAttributePath* attribute;
        attribute = [[MXEXmlAttributePath alloc] initWithPaths:@[@"hoge", @"fuga"]];
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":attribute});

        attribute = [[MXEXmlAttributePath alloc] initWithRootAttribute:@"hoge"];
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":attribute});
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
        expectedObj.attributes = @{@"status": @"OK"};

        MXEXmlNode* user1 = [[MXEXmlNode alloc] initWithElementName:@"user"];
        MXEXmlNode* user2 = [[MXEXmlNode alloc] initWithElementName:@"user"];
        MXEXmlNode* userId1 = [[MXEXmlNode alloc] initWithElementName:@"id"];
        MXEXmlNode* userId2 = [[MXEXmlNode alloc] initWithElementName:@"id"];
        userId1.children = @"1";
        user1.children = @[userId1];

        userId2.children = @"2";
        user2.children = @[userId2];
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

QuickSpecEnd
