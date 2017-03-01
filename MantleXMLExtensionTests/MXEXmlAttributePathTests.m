//
//  MXEXmlAttributePathTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/27.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlAttributePath.h"
#import "MXEXmlNode.h"

QuickSpecBegin(MXEXmlAttributePathTests)
{
    describe(@"initWithNodePath:attributeKey:", ^{
        it(@"failed, if attribute key's length is 0", ^{
            expect([[MXEXmlAttributePath alloc] initWithPathString:@"a.b" attributeKey:@""]).to(raiseException());
        });
    });

    describe(@"description", ^{
        it(@"is correct description", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"a.b", @"c");
            expect([path description]).to(equal(@"MXEXmlAttribute(@\"a.b\", @\"c\")"));
        });
    });

    describe(@"separatedPath", ^{
        it(@"is correct separatedPath", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@".a..b", @"c");
            expect([path separatedPath]).to(equal(@[ @"a", @"b" ]));
        });
    });

    describe(@"getValueFromXmlNode:", ^{
        /**
         * root --- child1
         *       |
         *       +- child2 -- grandChild1
         */
        MXEXmlNode* grandChild1 = [[MXEXmlNode alloc] initWithElementName:@"grandChild1"];
        MXEXmlNode* child1 = [[MXEXmlNode alloc] initWithElementName:@"child1"];
        MXEXmlNode* child2 = [[MXEXmlNode alloc] initWithElementName:@"child2"
                                                          attributes:@{ @"child2Attr1" : @"child2Attr1Value" }
                                                            children:@[ grandChild1 ]];
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                        attributes:@{ @"rootAttr1" : @"rootAttr1Value",
                                                                      @"rootAttr2" : @"rootAttr2Value" }
                                                          children:@[ child1, child2 ]];

        it(@"return attribute value, if attribute found", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"", @"rootAttr1");
            expect([path getValueFromXmlNode:root]).to(equal(@"rootAttr1Value"));
        });

        it(@"return nil, if attribute isn't found", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"", @"notFound");
            expect([path getValueFromXmlNode:root]).to(beNil());
        });

        it(@"can return the attribute of the child", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"child2", @"child2Attr1");
            expect([path getValueFromXmlNode:root]).to(equal(@"child2Attr1Value"));
        });

        it(@"return nil, if node does not exist", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"child1.notFound", @"attribute");
            expect([path getValueFromXmlNode:root]).to(beNil());
        });
    });

    describe(@"setValue:forXmlNode:", ^{
        /**
         * root --- child1
         *       |
         *       +- child2 -- grandChild1
         */
        MXEXmlNode* grandChild1 = [[MXEXmlNode alloc] initWithElementName:@"grandChild1"];
        MXEXmlNode* child1 = [[MXEXmlNode alloc] initWithElementName:@"child1"];
        MXEXmlNode* child2 = [[MXEXmlNode alloc] initWithElementName:@"child2"
                                                          attributes:@{ @"child2Attr1" : @"child2Attr1Value" }
                                                            children:@[ grandChild1 ]];
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                        attributes:@{ @"rootAttr1" : @"rootAttr1Value",
                                                                      @"rootAttr2" : @"rootAttr2Value" }
                                                          children:@[ child1, child2 ]];

        it(@"throw exception, if value is not string", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"a", @"b");
            MXEMutableXmlNode* node = [root mutableCopy];
            expectAction(^{
                [path setValue:@1 forXmlNode:node];
            }).to(raiseException());
        });

        it(@"delete an attribute, if value is nil", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"", @"rootAttr1");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:nil forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(beNil());
            expect(node.attributes).to(equal(@{ @"rootAttr2" : @"rootAttr2Value" }));
        });

        it(@"can update attribute, if the attribute already exists", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"", @"rootAttr1");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@"override!!" forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(@"override!!"));
        });

        it(@"add nodes, if some nodes in the path do not exist", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"child1.notFound", @"attribute");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@"attributeValue" forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(@"attributeValue"));
        });

        it(@"remove the attribute, if value is nil", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"child2", @"child2Attr1");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:nil forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(beNil());
            expect([node lookupChild:@"child2"].attributes).to(equal(@{}));
        });

        it(@"add some nodes in the path even if value is nil", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"child3", @"attribute");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:nil forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(beNil());
            expect([node lookupChild:@"child3"].attributes).to(equal(@{}));
        });
    });
}
QuickSpecEnd
