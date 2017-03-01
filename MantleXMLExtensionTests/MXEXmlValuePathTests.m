//
//  MXEXmlValuePathTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/13.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlValuePath.h"

QuickSpecBegin(MXEXmlValuePathTests)
{
    describe(@"description", ^{
        MXEXmlValuePath* path = MXEXmlValue(@"a.b");
        expect([path description]).to(equal(@"MXEXmlValue(@\"a.b\")"));
    });

    describe(@"separatedPath", ^{
        it(@"is correct separatedPath", ^{
            MXEXmlValuePath* path = MXEXmlValue(@".a..b");
            expect([path separatedPath]).to(equal(@[ @"a", @"b" ]));
        });
    });

    describe(@"getValueFromXmlNode:", ^{
        /**
         * root --- child
         *       |
         *       +- child2 -- grandChild1
         *       |
         *       +- child
         */
        MXEXmlNode* grandChild1 = [[MXEXmlNode alloc] initWithElementName:@"grandChild1"
                                                               attributes:nil
                                                                    value:@"grandChild1Value"];
        MXEXmlNode* child1 = [[MXEXmlNode alloc] initWithElementName:@"child"
                                                          attributes:nil
                                                               value:@"child1"];
        MXEXmlNode* child2 = [[MXEXmlNode alloc] initWithElementName:@"child2"
                                                          attributes:nil
                                                            children:@[ grandChild1 ]];
        MXEXmlNode* child3 = [[MXEXmlNode alloc] initWithElementName:@"child"
                                                          attributes:nil
                                                               value:@"child3"];
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                        attributes:nil
                                                          children:@[ child1, child2, child3 ]];

        it(@"can look node and return value", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child2.grandChild1");
            expect([path getValueFromXmlNode:root]).to(equal(@"grandChild1Value"));
        });

        it(@"return nil, when target node have children", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child2");
            expect([path getValueFromXmlNode:root]).to(beNil());
        });

        it(@"return nil, when node can not be found", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child2.grandChild2");
            expect([path getValueFromXmlNode:root]).to(beNil());
        });

        it(@"return value of the head node, if more than one node exist", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child");
            expect([path getValueFromXmlNode:root]).to(equal(@"child1"));
        });

        it(@"can return value of root", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"");
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                            attributes:nil
                                                                 value:@"root"];
            expect([path getValueFromXmlNode:node]).to(equal(@"root"));
        });
    });

    describe(@"setValue:forXmlNode:", ^{
        /**
         * root --- child
         *       |
         *       +- child2 -- grandChild1
         *       |
         *       +- child
         */
        MXEXmlNode* grandChild1 = [[MXEXmlNode alloc] initWithElementName:@"grandChild1"
                                                               attributes:nil
                                                                    value:@"grandChild1Value"];
        MXEXmlNode* child1 = [[MXEXmlNode alloc] initWithElementName:@"child"
                                                          attributes:nil
                                                               value:@"child1"];
        MXEXmlNode* child2 = [[MXEXmlNode alloc] initWithElementName:@"child2"
                                                          attributes:nil
                                                            children:@[ grandChild1 ]];
        MXEXmlNode* child3 = [[MXEXmlNode alloc] initWithElementName:@"child"
                                                          attributes:nil
                                                               value:@"child3"];
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                        attributes:nil
                                                          children:@[ child1, child2, child3 ]];

        it(@"can update the value", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child2.grandChild1");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@"overwrite" forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(@"overwrite"));
        });

        it(@"delete children and set the value, when target node have children", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child2");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@"overwrite" forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(@"overwrite"));
            expect([node lookupChild:@"child2"].hasChildren).to(equal(NO));
        });

        it(@"add nodes, if some nodes in the path do not exist", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child3.a.b");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@"value" forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(@"value"));
        });

        it(@"can update the value of root node", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@"root" forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(@"root"));
            expect([node hasChildren]).to(equal(NO));
        });

        it(@"update the head node, if more than one node exist", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@"overwrite" forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(@"overwrite"));
            expect(node.children[0].value).to(equal(@"overwrite"));
            expect(node.children[1].value).to(beNil());
            expect(node.children[2].value).to(equal(@"child3"));
        });

        it(@"delete the value, if value is nil", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:nil forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(beNil());
            expect(node.children[0].value).to(beNil());
            expect(node.children[1].value).to(beNil());
            expect(node.children[2].value).to(equal(@"child3"));
        });

        it(@"delete the children, if value is nil and target node have children", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child2");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:nil forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(beNil());
            expect([node lookupChild:@"child2"].children).to(beNil());
        });

        it(@"add some nodes in the path even if value is nil", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child3");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:nil forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(beNil());
            expect([node lookupChild:@"child3"]).to(equal([[MXEXmlNode alloc] initWithElementName:@"child3"]));
        });

        it(@"throw exception, if value is not NSString", ^{
            MXEXmlValuePath* path = MXEXmlValue(@"child3");
            MXEMutableXmlNode* node = [root mutableCopy];
            expectAction(^{
                [path setValue:@1 forXmlNode:node];
            }).to(raiseException());
        });
    });
}
QuickSpecEnd
