//
//  MXEXmlNodeTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlArrayPath.h"
#import "MXEXmlAttributePath.h"
#import "MXEXmlNode.h"
#import "MXEXmlNodePath.h"
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

    describe(@"description", ^{
        it(@"contains class name, if object class is MXEXmlNode", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                            attributes:@{ @"key1" : @"value1",
                                                                          @"key2" : @"value2" }
                                                              children:nil];
            expect([root description]).to(equal(@"MXEXmlNode # <object key1=\"value1\" key2=\"value2\" />"));
        });

        it(@"contains class name, if object class is MXEMutableXmlNode", ^{
            MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"
                                                            attributes:@{ @"key1" : @"value1",
                                                                          @"key2" : @"value2" }
                                                              children:nil];
            expect([[root mutableCopy] description]).to(equal(@"MXEMutableXmlNode # <object key1=\"value1\" key2=\"value2\" />"));
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

        it(@"returns NO, if comparison object is not MXEXmlNode", ^{
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"object"];
            expect([node isEqual:@1]).to(equal(NO));
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

    describe(@"setToCopyAllElementsFromXmlNode:", ^{
        it(@"can copy the node that have children", ^{
            MXEXmlNode* child = [[MXEXmlNode alloc] initWithElementName:@"child"];

            MXEMutableXmlNode* dstNode = [[MXEMutableXmlNode alloc] initWithElementName:@"a"];
            MXEXmlNode* srcNode = [[MXEXmlNode alloc] initWithElementName:@"source"
                                                               attributes:@{ @"attr" : @"value" }
                                                                 children:@[ child ]];

            [dstNode setToCopyAllElementsFromXmlNode:srcNode];
            expect(dstNode).to(equal(srcNode));
            expect([dstNode.children[0] isKindOfClass:MXEMutableXmlNode.class]).to(equal(YES));
        });

        it(@"can copy the node that have value", ^{
            MXEMutableXmlNode* dstNode = [[MXEMutableXmlNode alloc] initWithElementName:@"a"];
            MXEXmlNode* srcNode = [[MXEXmlNode alloc] initWithElementName:@"source"
                                                               attributes:@{ @"attr" : @"value" }
                                                                    value:@"value"];

            [dstNode setToCopyAllElementsFromXmlNode:srcNode];
            expect(dstNode).to(equal(srcNode));
        });
    });

    describe(@"toDictionary, initWithElementName:fromDictionary:", ^{
        it(@"can convert between dictionary and MXEXmlNode", ^{
            MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"a" attributes:nil value:nil];
            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"b" attributes:nil value:@"b1_v"];
            MXEXmlNode* cChild = [[MXEXmlNode alloc] initWithElementName:@"@c1" attributes:nil value:@"c1_v"];
            MXEXmlNode* c = [[MXEXmlNode alloc] initWithElementName:@"c"
                                                         attributes:@{ @"c1" : @"c1_attr" }
                                                           children:@[ cChild ]];
            MXEXmlNode* d = [[MXEXmlNode alloc] initWithElementName:@"d"
                                                         attributes:@{ @"d1" : @"d1_attr" }
                                                           children:nil];
            MXEXmlNode* e = [[MXEXmlNode alloc] initWithElementName:@"e"
                                                         attributes:@{ @"e1" : @"e1_attr" }
                                                              value:@"e1_v"];
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                            attributes:@{ @"a" : @"a1",
                                                                          @"b" : @"b1" }
                                                              children:@[ a, b, c, d, e ]];

            expect([node toDictionary])
                .to(equal(@{ @"@a" : @"a1",
                             @"@b" : @"b1",
                             @"a" : NSNull.null,
                             @"b" : @"b1_v",
                             @"c" : @{ @"@c1" : @"c1_attr" },
                             @"d" : @{ @"@d1" : @"d1_attr" },
                             @"e" : @{ @"@e1" : @"e1_attr", @"" : @"e1_v" } }));
            expect([[MXEXmlNode alloc] initWithElementName:node.elementName fromDictionary:node.toDictionary].toDictionary)
                .to(equal(node.toDictionary));
        });

        it(@"can convert between dictionary and MXEXmlNode, if root node have a value", ^{
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"root" attributes:nil value:@"root_v"];
            expect([node toDictionary]).to(equal(@{ @"" : @"root_v" }));
            expect([[MXEXmlNode alloc] initWithElementName:@"root" fromDictionary:[node toDictionary]])
                .to(equal(node));
        });

        it(@"throw exception, if attributes contains no string", ^{
            __block MXEXmlNode* node;
            expectAction(^{
                node = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                fromDictionary:@{ @"@a" : @{ @"a" : @"a_v" } }];
            }).to(raiseException());
        });

        it(@"throw exception, if dictionary contains value that is not supported", ^{
            __block MXEXmlNode* node;
            expectAction(^{
                node = [[MXEXmlNode alloc] initWithElementName:@"root" fromDictionary:@{ @"a" : @1 }];
            }).to(raiseException());
        });
    });
}
QuickSpecEnd
