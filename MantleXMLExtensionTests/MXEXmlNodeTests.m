//
//  MXEXmlNodeTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"
#import <Foundation/Foundation.h>

QuickSpecBegin(MXEXmlNodeTests)
{
    describe(@"toString", ^{

        it(@"attributes is exist, children isn't exist", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
            root.attributes = @{ @"key1" : @"value1",
                                 @"key2" : @"value2" };
            expect([root toString]).to(equal(@"<object key1=\"value1\" key2=\"value2\" />"));
        });

        it(@"The attribute values escaped", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
            root.attributes = @{ @"key" : @"escape string is \"'<>&" };
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
            root.attributes = @{ @"key1" : @"value1",
                                 @"key2" : @"value2" };
            MXEXmlNode* child = [[MXEXmlNode alloc] initWithElementName:@"2nd"];
            child.attributes = @{ @"key1" : @"value1",
                                  @"key2" : @"value2" };
            root.children = @[ [[MXEXmlNode alloc] initWithElementName:@"1st"],
                               child,
                               [[MXEXmlNode alloc] initWithElementName:@"3rd"] ];
            expect([root toString]).to(equal(@"<object key1=\"value1\" key2=\"value2\">"
                                             @"<1st />"
                                             @"<2nd key1=\"value1\" key2=\"value2\" />"
                                             @"<3rd />"
                                             @"</object>"));
        });
    });

    describe(@"isEqual:", ^{

        it(@"If the contents are the same, return YES", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
            a.attributes = @{ @"key1" : @"value1",
                              @"key2" : @"value2" };
            a.children = @"child";

            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"];
            b.attributes = @{ @"key1" : @"value1",
                              @"key2" : @"value2" };
            b.children = @"child";

            expect([a isEqual:b]).to(equal(YES));
        });

        it(@"If element name is different, return NO", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
            a.attributes = @{ @"key1" : @"value1",
                              @"key2" : @"value2" };
            a.children = @"child";

            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"another object"];
            b.attributes = @{ @"key1" : @"value1",
                              @"key2" : @"value2" };
            b.children = @"child";

            expect([a isEqual:b]).to(equal(NO));
        });

        it(@"If attributes is different, return NO", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
            a.attributes = @{ @"key1" : @"value1",
                              @"key2" : @"value2" };
            a.children = @"child";

            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"];
            b.attributes = @{ @"key1" : @"value1",
                              @"key2" : @"another value" };
            b.children = @"child";

            expect([a isEqual:b]).to(equal(NO));
        });

        it(@"If children is different, return NO", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
            a.attributes = @{ @"key1" : @"value1",
                              @"key2" : @"value2" };
            a.children = @"child";

            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"];
            b.attributes = @{ @"key1" : @"value1",
                              @"key2" : @"value2" };
            b.children = @"another child";

            expect([a isEqual:b]).to(equal(NO));
        });

        it(@"The order of attributes does not matter", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
            a.attributes = [NSMutableDictionary dictionary];
            ((NSMutableDictionary*)a.attributes)[@"key1"] = @"value1";
            ((NSMutableDictionary*)a.attributes)[@"key2"] = @"value2";

            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"];
            b.attributes = [NSMutableDictionary dictionary];
            ((NSMutableDictionary*)b.attributes)[@"key2"] = @"value2";
            ((NSMutableDictionary*)b.attributes)[@"key1"] = @"value1";

            expect([a isEqual:b]).to(equal(YES));
        });

        it(@"The order of children matter", ^{
            MXEXmlNode* root1 = [[MXEXmlNode alloc] initWithElementName:@"object"];
            MXEXmlNode* root2 = [[MXEXmlNode alloc] initWithElementName:@"object"];

            MXEXmlNode* a1 = [[MXEXmlNode alloc] initWithElementName:@"a"];
            a1.children = @"a1";
            MXEXmlNode* a2 = [[MXEXmlNode alloc] initWithElementName:@"a"];
            a2.children = @"a2";
            MXEXmlNode* a3 = [[MXEXmlNode alloc] initWithElementName:@"a"];
            a3.children = @"a3";

            root1.children = @[ a1, a2, a3 ];
            root2.children = @[ a3, a2, a1 ];

            expect([root1 isEqual:root2]).to(equal(NO));
        });

        it(@"Child that has the same all element are regarded as the same", ^{
            MXEXmlNode* root1 = [[MXEXmlNode alloc] initWithElementName:@"object"];
            MXEXmlNode* root2 = [[MXEXmlNode alloc] initWithElementName:@"object"];

            MXEXmlNode* a1 = [[MXEXmlNode alloc] initWithElementName:@"a"];
            MXEXmlNode* a2 = [[MXEXmlNode alloc] initWithElementName:@"a"];
            MXEXmlNode* a3 = [[MXEXmlNode alloc] initWithElementName:@"a"];

            root1.children = @[ a1, a2, a3 ];
            root2.children = @[ a3, a2, a1 ];

            expect([root1 isEqual:root2]).to(equal(YES));
        });
    });

    describe(@"initWithXmlPath:value:", ^{

        it(@"MXEXmlChildNodePath : value is nil", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithXmlPath:MXEXmlChildNode(@"a.b.c") value:nil];
            expect([a toString]).to(equal(@"<a><b /></a>"));
        });

        it(@"MXEXmlChildNodePath", ^{
            MXEXmlNode* value = [[MXEXmlNode alloc] initWithElementName:@"c"];
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithXmlPath:MXEXmlChildNode(@"a.b.c") value:value];
            expect([a toString]).to(equal(@"<a><b><c /></b></a>"));
        });

        it(@"MXEXmlArrayPath : value is nil", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithXmlPath:MXEXmlArray(@"a.b", @"c") value:nil];
            expect([a toString]).to(equal(@"<a><b /></a>"));
        });

        it(@"MXEXmlArrayPath : array of value", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithXmlPath:MXEXmlArray(@"a.b", @"c") value:@[ @"value1", @"value2" ]];
            expect([a toString]).to(equal(@"<a><b><c>value1</c><c>value2</c></b></a>"));
        });

        it(@"MXEXmlAttributePath : value is nil", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithXmlPath:MXEXmlAttribute(@"a.b", @"c") value:nil];
            expect([a toString]).to(equal(@"<a><b /></a>"));
        });

        it(@"MXEXmlAttributePath", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithXmlPath:MXEXmlAttribute(@"a.b", @"c") value:@"value1"];
            expect([a toString]).to(equal(@"<a><b c=\"value1\" /></a>"));
        });

        it(@"MXEXmlPath : value is nil", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithXmlPath:[MXEXmlPath pathWithNodePath:@"a.b.c"] value:nil];
            expect([a toString]).to(equal(@"<a><b><c /></b></a>"));
        });

        it(@"MXEXmlPath", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithXmlPath:[MXEXmlPath pathWithNodePath:@"a.b.c"] value:@"value"];
            expect([a toString]).to(equal(@"<a><b><c>value</c></b></a>"));
        });
    });

    describe(@"lookupChild:", ^{

        it(@"found / not found", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"a"];
            a.children = @[ [[MXEXmlNode alloc] initWithElementName:@"c"] ];
            MXEXmlNode* b1 = [[MXEXmlNode alloc] initWithElementName:@"b"];
            b1.attributes = @{ @"key" : @"b1" };
            MXEXmlNode* b2 = [[MXEXmlNode alloc] initWithElementName:@"b"];
            b2.attributes = @{ @"key" : @"b2" };
            MXEXmlNode* c = [[MXEXmlNode alloc] initWithElementName:@"c"];
            c.children = @"c";

            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"a"];
            root.children = @[ a, b1, b2, c ];

            expect([root lookupChild:@"a"].elementName).to(equal(@"a"));
            expect([root lookupChild:@"b"].attributes[@"key"]).to(equal(@"b1"));
            expect([root lookupChild:@"c"].children).to(equal(@"c"));
            expect([root lookupChild:@"d"]).to(beNil());
        });
    });

    describe(@"getForXmlPath: and setValue:forXmlPath:", ^{

        it(@"root node's child", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
            [root setValue:@"value1" forXmlPath:[MXEXmlPath pathWithNodePath:@"a"]];
            expect([root toString]).to(equal(@"<object><a>value1</a></object>"));

            [root setValue:@"value2" forXmlPath:[MXEXmlPath pathWithNodePath:@"b"]];
            expect([root toString]).to(equal(@"<object><a>value1</a><b>value2</b></object>"));

            expect([root getForXmlPath:[MXEXmlPath pathWithNodePath:@"a"]]).to(equal(@"value1"));
            expect([root getForXmlPath:[MXEXmlPath pathWithNodePath:@"b"]]).to(equal(@"value2"));
        });

        it(@"root node's grandchild", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
            [root setValue:@"value1" forXmlPath:[MXEXmlPath pathWithNodePath:@"a.b"]];
            expect([root toString]).to(equal(@"<object><a><b>value1</b></a></object>"));

            [root setValue:@"value2" forXmlPath:[MXEXmlPath pathWithNodePath:@"a.c"]];
            expect([root toString]).to(equal(@"<object><a><b>value1</b><c>value2</c></a></object>"));

            expect([root getForXmlPath:[MXEXmlPath pathWithNodePath:@"a.b"]]).to(equal(@"value1"));
            expect([root getForXmlPath:[MXEXmlPath pathWithNodePath:@"a.c"]]).to(equal(@"value2"));
        });

        it(@"If node is already exist, overwrite the value", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
            [root setValue:@"value1" forXmlPath:[MXEXmlPath pathWithNodePath:@"a.b"]];
            expect([root toString]).to(equal(@"<object><a><b>value1</b></a></object>"));

            [root setValue:@"value2" forXmlPath:[MXEXmlPath pathWithNodePath:@"a.b"]];
            expect([root toString]).to(equal(@"<object><a><b>value2</b></a></object>"));

            expect([root getForXmlPath:[MXEXmlPath pathWithNodePath:@"a.b"]]).to(equal(@"value2"));
        });
    });
}
QuickSpecEnd
