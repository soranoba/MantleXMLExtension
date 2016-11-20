//
//  MXEXmlNodeTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXEXmlNode.h"

QuickSpecBegin(MXEXmlNodeTests)

describe(@"toString", ^{

    it(@"attributes is exist, children isn't exist", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        root.attributes = @{@"key1":@"value1", @"key2":@"value2"};
        expect([root toString]).to(equal(@"<object key1=\"value1\" key2=\"value2\" />"));
    });

    it(@"The attribute values escaped", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        root.attributes = @{@"key":@"escape string is \"'<>&"};
        expect([root toString]).to(equal(@"<object key=\"escape string is &quot;&apos;&lt;&gt;&amp;\" />"));
    });

    it(@"The children escaped", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        root.children = @"escape string is \"'<>&";
        expect([root toString]).to(equal(@"<object>escape string is &quot;&apos;&lt;&gt;&amp;</object>"));
    });

    it(@"attributes isn't exist, children isn't exist", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        expect([root toString]).to(equal(@"<object />"));
    });

    it(@"attributes isn't exist, children is exist", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        root.children = @[ [[MXEXmlNode alloc] initWithElementName:@"1st"],
                           [[MXEXmlNode alloc] initWithElementName:@"2nd"] ];
        expect([root toString]).to(equal(@"<object><1st /><2nd /></object>"));
    });

    it(@"attribute is exist, children is exist", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        root.attributes = @{@"key1":@"value1", @"key2":@"value2"};
        MXEXmlNode* child = [[MXEXmlNode alloc] initWithElementName:@"2nd"];
        child.attributes = @{@"key1":@"value1", @"key2":@"value2"};
        root.children = @[ [[MXEXmlNode alloc] initWithElementName:@"1st"],
                           child,
                           [[MXEXmlNode alloc] initWithElementName:@"3rd"]];
        expect([root toString]).to(equal(@"<object key1=\"value1\" key2=\"value2\">"
                                         @"<1st />"
                                         @"<2nd key1=\"value1\" key2=\"value2\" />"
                                         @"<3rd />"
                                         @"</object>"));
    });
});

describe(@"-isEqual:", ^{

    it(@"isEqual: is correct. Attribute does not depend on the order", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        a.attributes = @{@"key1":@"value1", @"key2":@"value2"};
        a.children   = @"hoge";

        MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"];
        b.attributes = @{@"key2":@"value2", @"key1":@"value1"};
        b.children   = @"hoge";
        expect(a).to(equal(b));
    });

    it(@"Children depend on the order", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        a.children = @[[[MXEXmlNode alloc] initWithElementName:@"child1"],
                       [[MXEXmlNode alloc] initWithElementName:@"child2"]];
        MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"];
        b.children = @[[[MXEXmlNode alloc] initWithElementName:@"child2"],
                       [[MXEXmlNode alloc] initWithElementName:@"child1"]];
        expect(a).notTo(equal(b));
    });

    it(@"Attribute and children are different", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        a.attributes = @{@"key1":@"value1", @"key2":@"value2"};

        MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"];

        MXEXmlNode* key1 = [[MXEXmlNode alloc] initWithElementName:@"key1"];
        key1.children = @"value1";
        MXEXmlNode* key2 = [[MXEXmlNode alloc] initWithElementName:@"key2"];
        key2.children = @"value2";

        b.children = @[ key1, key2 ];
        expect(a).notTo(equal(b));
    });
});

QuickSpecEnd
