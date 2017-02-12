//
//  MXEXmlArrayPathTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/27.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlArrayPath.h"
#import "MXEXmlAttributePath.h"
#import "MXEXmlChildNodePath.h"
#import "MXEXmlNode.h"
#import "MXEXmlValuePath.h"

@interface MXEXmlArrayPath ()
@property (nonatomic, nonnull, strong) MXEXmlNodePath* parentNodePath;
@property (nonatomic, nonnull, strong) id<MXEXmlAccessible> collectRelativePath;
@end

QuickSpecBegin(MXEXmlArrayPathTests)
{
    describe(@"initWithParentPathString:collectRelativePath:", ^{
        it(@"throw exception, if collectRelativePath isn't MXEXmlAccessible or NSString", ^{
            expect([[MXEXmlArrayPath alloc] initWithParentPathString:@"a.b" collectRelativePath:@1]).to(raiseException());
        });

        it(@"return a instance, if collectRelativePath is MXEXmlPath", ^{
            MXEXmlArrayPath* path = [[MXEXmlArrayPath alloc] initWithParentPathString:@"a.b"
                                                                  collectRelativePath:MXEXmlChildNode(@"a.c")];
            expect([path.collectRelativePath isKindOfClass:MXEXmlNodePath.class]).to(equal(YES));
            expect(path.collectRelativePath.separatedPath).to(equal(@[ @"a", @"c" ]));
        });

        it(@"return a instance, if collectRelativePath is string", ^{
            MXEXmlArrayPath* path = [[MXEXmlArrayPath alloc] initWithParentPathString:@"a.b"
                                                                  collectRelativePath:@"c.d"];
            expect([path.collectRelativePath isKindOfClass:MXEXmlValuePath.class]).to(equal(YES));
            expect(path.collectRelativePath.separatedPath).to(equal(@[ @"c", @"d" ]));
        });
    });

    describe(@"description", ^{
        it(@"is correct description", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"a.b", @"c");
            expect([path description]).to(equal(@"MXEXmlArray(@\"a.b\", MXEXmlValue(@\"c\"))"));
        });
    });

    describe(@"separatedPath", ^{
        it(@"is correct separatedPath", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@".a..b", @"c");
            expect([path separatedPath]).to(equal(@[ @"a", @"b" ]));
        });
    });

    describe(@"getValueFromXmlNode:", ^{
        /**
         * root --- a --- c
         *       |
         *       +- a
         *       |
         *       +- a -+- c
         *       |     |
         *       |     +- d
         *       +- b
         *       |
         *       +- b
         */
        MXEXmlNode* d1 = [[MXEXmlNode alloc] initWithElementName:@"d"
                                                      attributes:nil
                                                           value:@"d1"];
        MXEXmlNode* c1 = [[MXEXmlNode alloc] initWithElementName:@"c"
                                                      attributes:nil
                                                           value:@"c1"];
        MXEXmlNode* c2 = [[MXEXmlNode alloc] initWithElementName:@"c"
                                                      attributes:nil
                                                           value:@"c2"];
        MXEXmlNode* b1 = [[MXEXmlNode alloc] initWithElementName:@"b"
                                                      attributes:nil
                                                           value:@"b1"];
        MXEXmlNode* b2 = [[MXEXmlNode alloc] initWithElementName:@"b"
                                                      attributes:nil
                                                           value:@"b2"];
        MXEXmlNode* a1 = [[MXEXmlNode alloc] initWithElementName:@"a"
                                                      attributes:@{ @"a_1" : @"a1",
                                                                    @"a_2" : @"a1" }
                                                        children:@[ c1 ]];
        MXEXmlNode* a2 = [[MXEXmlNode alloc] initWithElementName:@"a"
                                                      attributes:@{ @"a_1" : @"a2",
                                                                    @"a_3" : @"a2" }
                                                           value:@"a2"];
        MXEXmlNode* a3 = [[MXEXmlNode alloc] initWithElementName:@"a"
                                                      attributes:@{ @"a_3" : @"a3" }
                                                        children:@[ c2, d1 ]];
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                        attributes:@{ @"r_1" : @"root" }
                                                          children:@[ a1, a2, a3, b1, b2 ]];

        it(@"can return list of attributes", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"", MXEXmlAttribute(@"a", @"a_1"));
            expect([path getValueFromXmlNode:root]).to(equal(@[ @"a1", @"a2" ]));
        });

        it(@"can return root attribute, if parent node is empty string", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"", MXEXmlAttribute(@"", @"r_1"));
            expect([path getValueFromXmlNode:root]).to(equal(@[ @"root" ]));
        });

        it(@"return nil, if parent node does not exist", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"a.b", @"c");
            expect([path getValueFromXmlNode:root]).to(beNil());
        });

        it(@"return empty list, if parent node exist, but target is not found", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"b", @"c");
            expect([path getValueFromXmlNode:root]).to(equal(@[]));
        });

        it(@"can return list of child node", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"", MXEXmlChildNode(@"a"));
            expect([path getValueFromXmlNode:root]).to(equal(@[ a1, a2, a3 ]));
        });

        it(@"can return list of value", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"", @"a.c");
            expect([path getValueFromXmlNode:root]).to(equal(@[ @"c1", @"c2" ]));
        });

        it(@"selected the one at the head, if there are multiple parents", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"a", @"c");
            expect([path getValueFromXmlNode:root]).to(equal(@[ @"c1" ]));
        });
    });

    describe(@"setValue:forXmlNode:", ^{
        /**
         * root --- a --- c
         *       |
         *       +- a
         *       |
         *       +- a -+- c
         *       |     |
         *       |     +- d
         *       +- b
         *       |
         *       +- b
         */
        MXEXmlNode* d1 = [[MXEXmlNode alloc] initWithElementName:@"d"
                                                      attributes:nil
                                                           value:@"d1"];
        MXEXmlNode* c1 = [[MXEXmlNode alloc] initWithElementName:@"c"
                                                      attributes:nil
                                                           value:@"c1"];
        MXEXmlNode* c2 = [[MXEXmlNode alloc] initWithElementName:@"c"
                                                      attributes:nil
                                                           value:@"c2"];
        MXEXmlNode* b1 = [[MXEXmlNode alloc] initWithElementName:@"b"
                                                      attributes:nil
                                                           value:@"b1"];
        MXEXmlNode* b2 = [[MXEXmlNode alloc] initWithElementName:@"b"
                                                      attributes:nil
                                                           value:@"b2"];
        MXEXmlNode* a1 = [[MXEXmlNode alloc] initWithElementName:@"a"
                                                      attributes:@{ @"a_1" : @"a1",
                                                                    @"a_2" : @"a1" }
                                                        children:@[ c1 ]];
        MXEXmlNode* a2 = [[MXEXmlNode alloc] initWithElementName:@"a"
                                                      attributes:@{ @"a_1" : @"a2",
                                                                    @"a_3" : @"a2" }
                                                           value:@"a2"];
        MXEXmlNode* a3 = [[MXEXmlNode alloc] initWithElementName:@"a"
                                                      attributes:@{ @"a_3" : @"a3" }
                                                        children:@[ c2, d1 ]];
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                        attributes:@{ @"r_1" : @"root" }
                                                          children:@[ a1, a2, a3, b1, b2 ]];

        it(@"throw exception, if value is not array", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"a", @"b");
            MXEMutableXmlNode* node = [root mutableCopy];
            expectAction(^{
                [path setValue:@1 forXmlNode:node];
            }).to(raiseException());
        });

        it(@"update the value by only the number of elements of the array", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"", @"a");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@[ @"overwrite1", @"overwrite2" ] forXmlNode:node];
            expect(node.children[0].hasChildren).to(equal(NO));
            expect(node.children[0].value).to(equal(@"overwrite1"));
            expect(node.children[1].hasChildren).to(equal(NO));
            expect(node.children[1].value).to(equal(@"overwrite2"));
            expect(node.children[2].hasChildren).to(equal(YES));
        });

        it(@"add some nodes, if the number of target is less than the number of elements in array", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"", @"a");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@[ @"overwrite1", @"overwrite2", @"overwrite3", @"overwrite4" ] forXmlNode:node];
            expect(node.children[0].hasChildren).to(equal(NO));
            expect(node.children[0].value).to(equal(@"overwrite1"));
            expect(node.children[1].hasChildren).to(equal(NO));
            expect(node.children[1].value).to(equal(@"overwrite2"));
            expect(node.children[2].hasChildren).to(equal(NO));
            expect(node.children[2].value).to(equal(@"overwrite3"));
            expect(node.children[3]).to(equal(b1));
            expect(node.children[4]).to(equal(b2));
            expect(node.children[5]).to(equal([[MXEXmlNode alloc] initWithElementName:@"a"
                                                                           attributes:nil
                                                                                value:@"overwrite4"]));
        });

        it(@"can update attributes", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"a", MXEXmlAttribute(@"b", @"c"));
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@[ @"1", @"2", @"3" ] forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(@[ @"1", @"2", @"3" ]));
        });

        it(@"can update values", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"a", @"b.c");
            MXEMutableXmlNode* node = [root mutableCopy];
            [path setValue:@[ @"1", @"2", @"3" ] forXmlNode:node];
            expect([path getValueFromXmlNode:node]).to(equal(@[ @"1", @"2", @"3" ]));
        });

    });
}
QuickSpecEnd
