//
//  MXEXmlNodeTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlArrayPath+Private.h"
#import "MXEXmlAttributePath+Private.h"
#import "MXEXmlChildNodePath+Private.h"
#import "MXEXmlNode.h"
#import "MXEXmlPath+Private.h"
#import <Foundation/Foundation.h>

QuickSpecBegin(MXEXmlNodeTests)
{
    describe(@"toString", ^{

        it(@"attributes is exist, children isn't exist", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                            attributes:@{ @"key1" : @"value1",
                                                                          @"key2" : @"value2" }
                                                              children:nil];
            expect([root toString]).to(equal(@"<object key1=\"value1\" key2=\"value2\" />"));
        });

        it(@"The attribute values escaped", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                            attributes:@{ @"key" : @"escape string is \"'<>&" }
                                                              children:nil];
            expect([root toString]).to(equal(@"<object key=\"escape string is &quot;&apos;&lt;&gt;&amp;\" />"));
        });

        it(@"The children escaped", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                            attributes:nil
                                                                 value:@"escape string is \"'<>&"];
            expect([root toString]).to(equal(@"<object>escape string is &quot;&apos;&lt;&gt;&amp;</object>"));
        });

        it(@"attributes isn't exist, children isn't exist", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
            expect([root toString]).to(equal(@"<object />"));
        });

        it(@"attributes isn't exist, children is exist", ^{
            MXEMutableXmlNode* root = [[MXEMutableXmlNode alloc] initWithElementName:@"object"];
            [root addChild:[[MXEXmlNode alloc] initWithElementName:@"1st"]];
            [root addChild:[[MXEXmlNode alloc] initWithElementName:@"2nd"]];
            expect([root toString]).to(equal(@"<object><1st /><2nd /></object>"));
        });

        it(@"attribute is exist, children is exist", ^{
            MXEMutableXmlNode* root = [[MXEMutableXmlNode alloc] initWithElementName:@"object"
                                                                          attributes:@{ @"key1" : @"value1",
                                                                                        @"key2" : @"value2" }
                                                                            children:nil];
            MXEXmlNode* child = [[MXEXmlNode alloc] initWithElementName:@"2nd"
                                                             attributes:@{ @"key1" : @"value1",
                                                                           @"key2" : @"value2" }
                                                               children:nil];
            [root addChild:[[MXEXmlNode alloc] initWithElementName:@"1st"]];
            [root addChild:child];
            [root addChild:[[MXEXmlNode alloc] initWithElementName:@"3rd"]];
            expect([root toString]).to(equal(@"<object key1=\"value1\" key2=\"value2\">"
                                             @"<1st />"
                                             @"<2nd key1=\"value1\" key2=\"value2\" />"
                                             @"<3rd />"
                                             @"</object>"));
        });
    });

    describe(@"isEqual:", ^{

        it(@"If the contents are the same, return YES", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                         attributes:@{ @"key1" : @"value1",
                                                                       @"key2" : @"value2" }
                                                              value:@"child"];

            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                         attributes:@{ @"key1" : @"value1",
                                                                       @"key2" : @"value2" }
                                                              value:@"child"];

            expect([a isEqual:b]).to(equal(YES));
        });

        it(@"If element name is different, return NO", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                         attributes:@{ @"key1" : @"value1",
                                                                       @"key2" : @"value2" }
                                                              value:@"child"];

            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"another object"
                                                         attributes:@{ @"key1" : @"value1",
                                                                       @"key2" : @"value2" }
                                                              value:@"child"];
            expect([a isEqual:b]).to(equal(NO));
        });

        it(@"If attributes is different, return NO", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                         attributes:@{ @"key1" : @"value1",
                                                                       @"key2" : @"value2" }
                                                              value:@"child"];

            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                         attributes:@{ @"key1" : @"value1",
                                                                       @"key2" : @"another value" }
                                                              value:@"child"];

            expect([a isEqual:b]).to(equal(NO));
        });

        it(@"If children is different, return NO", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                         attributes:@{ @"key1" : @"value1",
                                                                       @"key2" : @"value2" }
                                                              value:@"child"];

            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                         attributes:@{ @"key1" : @"value1",
                                                                       @"key2" : @"value2" }
                                                              value:@"another child"];

            expect([a isEqual:b]).to(equal(NO));
        });

        it(@"The order of attributes does not matter", ^{
            MXEMutableXmlNode* a = [[MXEMutableXmlNode alloc] initWithElementName:@"object"];
            a.attributes[@"key1"] = @"value1";
            a.attributes[@"key2"] = @"value2";

            MXEMutableXmlNode* b = [[MXEMutableXmlNode alloc] initWithElementName:@"object"];
            b.attributes[@"key2"] = @"value2";
            b.attributes[@"key1"] = @"value1";

            expect([a isEqual:b]).to(equal(YES));
        });

        it(@"The order of children matter", ^{
            MXEMutableXmlNode* root1 = [[MXEMutableXmlNode alloc] initWithElementName:@"object"];
            MXEMutableXmlNode* root2 = [[MXEMutableXmlNode alloc] initWithElementName:@"object"];

            MXEMutableXmlNode* a1 = [[MXEMutableXmlNode alloc] initWithElementName:@"a"];
            a1.value = @"a1";
            MXEMutableXmlNode* a2 = [[MXEMutableXmlNode alloc] initWithElementName:@"a"];
            a2.value = @"a2";
            MXEMutableXmlNode* a3 = [[MXEMutableXmlNode alloc] initWithElementName:@"a"];
            a3.value = @"a3";

            [root1 addChild:a1];
            [root1 addChild:a2];
            [root1 addChild:a3];

            [root2 addChild:a3];
            [root2 addChild:a2];
            [root2 addChild:a1];

            expect([root1 isEqual:root2]).to(equal(NO));
        });

        it(@"Child that has the same all element are regarded as the same", ^{
            MXEMutableXmlNode* root1 = [[MXEMutableXmlNode alloc] initWithElementName:@"object"];
            MXEMutableXmlNode* root2 = [[MXEMutableXmlNode alloc] initWithElementName:@"object"];

            MXEMutableXmlNode* a1 = [[MXEMutableXmlNode alloc] initWithElementName:@"a"];
            MXEMutableXmlNode* a2 = [[MXEMutableXmlNode alloc] initWithElementName:@"a"];
            MXEMutableXmlNode* a3 = [[MXEMutableXmlNode alloc] initWithElementName:@"a"];

            [root1 addChild:a1];
            [root1 addChild:a2];
            [root1 addChild:a3];

            [root2 addChild:a3];
            [root2 addChild:a2];
            [root2 addChild:a1];

            expect([root1 isEqual:root2]).to(equal(YES));
        });

        it(@"returns YES, when it compare immutable node and mutable node with same content", ^{
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                            attributes:@{ @"a" : @"a" }
                                                                 value:@"child"];
            expect([[node mutableCopy] isEqual:node]).to(equal(YES));
            expect([node isEqual:[node mutableCopy]]).to(equal(YES));
        });
    });

    describe(@"copying, mustablecopying", ^{
        it(@"shallow copy, when it call MXEXmlNode # copy", ^{
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"elementName"];
            MXEXmlNode* copyNode = [node copy];
            expect(copyNode != node).to(equal(YES));
            expect(copyNode).to(equal(node));
        });

        it(@"returns MXEMutableXmlNode, when it call MXEXmlNode # mutableCopy", ^{
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"elementName"
                                                            attributes:@{ @"a" : @"a" }
                                                                 value:@"child"];
            MXEMutableXmlNode* copyNode = [node mutableCopy];
            expect(copyNode).to(equal(node));
            expect([copyNode isKindOfClass:MXEMutableXmlNode.class]).to(equal(YES));
            expect(copyNode.elementName == node.elementName).to(equal(YES));
            expect(copyNode.attributes != node.attributes).to(equal(YES));
            expect(copyNode.children == node.children).to(equal(YES));
        });

        it(@"shallow copy, when it call MXEMutableXmlNode # copy", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"elementName"
                                                                          attributes:@{ @"a" : @"a" }
                                                                               value:@"child"];
            MXEMutableXmlNode* copyNode = [node copy];
            expect(copyNode).to(equal(node));
            expect(copyNode != node).to(equal(YES));
            expect(copyNode.elementName == node.elementName).to(equal(YES));
            expect(copyNode.attributes != node.attributes).to(equal(YES));
            expect(copyNode.children == node.children).to(equal(YES));
        });

        it(@"shallow copy, when it call MXEMutableXmlNode # mutableCopy", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"elementName"
                                                                          attributes:@{ @"a" : @"a" }
                                                                               value:@"child"];
            MXEMutableXmlNode* copyNode = [node mutableCopy];
            expect(copyNode).to(equal(node));
            expect(copyNode != node).to(equal(YES));
            expect(copyNode.elementName == node.elementName).to(equal(YES));
            expect(copyNode.attributes != node.attributes).to(equal(YES));
            expect(copyNode.children == node.children).to(equal(YES));
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

    describe(@"isEmpty", ^{
        it(@"returns YES, if it is no attributes and no children", ^{
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"a"];
            expect(node.isEmpty).to(equal(YES));
        });

        it(@"returns NO, if it have some attributes or some children", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"a"
                                                                          attributes:nil
                                                                               value:@"a"];
            expect(node.isEmpty).to(equal(NO));

            node.children = nil;
            node.attributes[@"a"] = @"b";
            expect(node.isEmpty).to(equal(NO));
        });
    });

    describe(@"lookupChild:", ^{

        it(@"found / not found", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"a"
                                                         attributes:nil
                                                           children:@[ [[MXEXmlNode alloc] initWithElementName:@"c"] ]];
            MXEXmlNode* b1 = [[MXEXmlNode alloc] initWithElementName:@"b"
                                                          attributes:@{ @"key" : @"b1" }
                                                            children:nil];
            MXEXmlNode* b2 = [[MXEXmlNode alloc] initWithElementName:@"b"
                                                          attributes:@{ @"key" : @"b2" }
                                                            children:nil];
            MXEXmlNode* c = [[MXEXmlNode alloc] initWithElementName:@"c"
                                                         attributes:nil
                                                              value:@"c"];

            MXEMutableXmlNode* root = [[MXEMutableXmlNode alloc] initWithElementName:@"a"];
            [root addChild:a];
            [root addChild:b1];
            [root addChild:b2];
            [root addChild:c];

            expect([root lookupChild:@"a"].elementName).to(equal(@"a"));
            expect([root lookupChild:@"b"].attributes[@"key"]).to(equal(@"b1"));
            expect([root lookupChild:@"c"].value).to(equal(@"c"));
            expect([root lookupChild:@"d"]).to(beNil());
        });
    });

    describe(@"getForXmlPath: and setValue:forXmlPath:", ^{

        it(@"root node's child", ^{
            MXEMutableXmlNode* root = [[MXEMutableXmlNode alloc] initWithElementName:@"object"];
            [root setValue:@"value1" forXmlPath:[MXEXmlPath pathWithNodePath:@"a"]];
            expect([root toString]).to(equal(@"<object><a>value1</a></object>"));

            [root setValue:@"value2" forXmlPath:[MXEXmlPath pathWithNodePath:@"b"]];
            expect([root toString]).to(equal(@"<object><a>value1</a><b>value2</b></object>"));

            expect([root getForXmlPath:[MXEXmlPath pathWithNodePath:@"a"]]).to(equal(@"value1"));
            expect([root getForXmlPath:[MXEXmlPath pathWithNodePath:@"b"]]).to(equal(@"value2"));
        });

        it(@"root node's grandchild", ^{
            MXEMutableXmlNode* root = [[MXEMutableXmlNode alloc] initWithElementName:@"object"];
            [root setValue:@"value1" forXmlPath:[MXEXmlPath pathWithNodePath:@"a.b"]];
            expect([root toString]).to(equal(@"<object><a><b>value1</b></a></object>"));

            [root setValue:@"value2" forXmlPath:[MXEXmlPath pathWithNodePath:@"a.c"]];
            expect([root toString]).to(equal(@"<object><a><b>value1</b><c>value2</c></a></object>"));

            expect([root getForXmlPath:[MXEXmlPath pathWithNodePath:@"a.b"]]).to(equal(@"value1"));
            expect([root getForXmlPath:[MXEXmlPath pathWithNodePath:@"a.c"]]).to(equal(@"value2"));
        });

        it(@"If node is already exist, overwrite the value", ^{
            MXEMutableXmlNode* root = [[MXEMutableXmlNode alloc] initWithElementName:@"object"];
            [root setValue:@"value1" forXmlPath:[MXEXmlPath pathWithNodePath:@"a.b"]];
            expect([root toString]).to(equal(@"<object><a><b>value1</b></a></object>"));

            [root setValue:@"value2" forXmlPath:[MXEXmlPath pathWithNodePath:@"a.b"]];
            expect([root toString]).to(equal(@"<object><a><b>value2</b></a></object>"));

            expect([root getForXmlPath:[MXEXmlPath pathWithNodePath:@"a.b"]]).to(equal(@"value2"));
        });
    });
}
QuickSpecEnd
