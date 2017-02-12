//
//  MXEXmlNodePathTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/12.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNodePath.h"

QuickSpecBegin(MXEXmlNodePathTests)
{
    describe(@"separatePathString:", ^{
        it(@"exclude empty characters", ^{
            NSArray* array1 = [MXEXmlNodePath separatePathString:@".."];
            expect(array1.count).to(equal(0));

            NSArray* array2 = [MXEXmlNodePath separatePathString:@".a..b."];
            expect(array2.count).to(equal(2));
            expect(array2[0]).to(equal(@"a"));
            expect(array2[1]).to(equal(@"b"));
        });

        it(@"return empty array, when path string is nil", ^{
            expect([MXEXmlNodePath separatePathString:nil]).to(equal(@[]));
        });
    });

    describe(@"description", ^{
        it(@"is correct description", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@"a.b"];
            expect([path description]).to(equal(@"@\"a.b\""));
        });
    });

    describe(@"separatedPath", ^{
        it(@"is correct separatedPath", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@".a..b"];
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
        MXEXmlNode* grandChild1 = [[MXEXmlNode alloc] initWithElementName:@"grandChild1"];
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

        it(@"can look node and return it", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@"child2.grandChild1"];
            expect([path getValueFromXmlNode:root]).to(equal(grandChild1));
        });

        it(@"return root, when path sepcify the root", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@""];
            expect([path getValueFromXmlNode:root]).to(equal(root));
        });

        it(@"return nil, when node can not be found", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@"child2.grandChild2"];
            expect([path getValueFromXmlNode:root]).to(beNil());
        });

        it(@"return the head node, if more than one node exist", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@"child"];
            expect([path getValueFromXmlNode:root]).to(equal(child1));
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
        MXEXmlNode* grandChild1 = [[MXEXmlNode alloc] initWithElementName:@"grandChild1"];
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

        it(@"can add the node", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@"child2.grandChild2"];
            MXEXmlNode* grandChild2 = [[MXEXmlNode alloc] initWithElementName:@"grandChild2"];

            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:grandChild2 forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(grandChild2));
        });

        it(@"overwrite node, when a node indicated by path is found", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@"child2.grandChild1"];
            MXEXmlNode* grandChild1 = [[MXEXmlNode alloc] initWithElementName:@"grandChild1"
                                                                   attributes:@{ @"attribute" : @"attributeValue" }
                                                                        value:@"override!!!"];

            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:grandChild1 forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(grandChild1));
        });

        it(@"add nodes, if some nodes in the path do not exist", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@"child3.a.b"];
            MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"b"];

            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:b forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(b));
        });

        it(@"can override root node", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@""];
            MXEXmlNode* overrideRoot = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                                    attributes:nil
                                                                         value:@"override!!"];

            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:overrideRoot forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(overrideRoot));
        });

        it(@"is automatically corrected, if the element name of the node to be set is wrong", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@"child2.correctName"];
            MXEXmlNode* wrongNode = [[MXEXmlNode alloc] initWithElementName:@"wrongName"
                                                                 attributes:@{ @"attribute" : @"attributeValue" }
                                                                      value:@"written node!!"];
            MXEXmlNode* correctNode = [[MXEXmlNode alloc] initWithElementName:@"correctName"
                                                                   attributes:@{ @"attribute" : @"attributeValue" }
                                                                        value:@"written node!!"];

            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:wrongNode forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(correctNode));
        });

        it(@"overwrite the head node, if more than one node exist", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@"child"];
            MXEXmlNode* nodeToSet = [[MXEXmlNode alloc] initWithElementName:@"child"
                                                                 attributes:nil
                                                                      value:@"overwrite"];
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:nodeToSet forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(nodeToSet));
            expect(node.children).to(equal(@[ nodeToSet, child2, child3 ]));
        });

        it(@"delete the node, if value is nil", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@"child"];
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:nil forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(child3));
            expect(node.children).to(equal(@[ child2, child3 ]));
        });

        it(@"throw exception, if trying to overwrite nil to root", ^{
            MXEXmlNodePath* path = [MXEXmlNodePath pathWithPathString:@""];
            MXEMutableXmlNode* node = [root mutableCopy];
            expectAction(^{
                [path setValue:nil forXmlNode:node];
            }).to(raiseException());
        });
    });
}
QuickSpecEnd
