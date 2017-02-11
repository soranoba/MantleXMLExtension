//
//  MXEXmlArrayPathTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/27.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlArrayPath+Private.h"
#import "MXEXmlNode.h"

QuickSpecBegin(MXEXmlArrayPathTests)
{
    describe(@"initWithParentNodePath:collectRelativePath:", ^{
        it(@"failed, if collectRelativePath isn't MXEXmlPath or string", ^{
            expect([[MXEXmlArrayPath alloc] initWithParentNodePath:@"a.b" collectRelativePath:@1]).to(raiseException());
        });

        it(@"return a instance, if collectRelativePath is MXEXmlPath", ^{
            MXEXmlArrayPath* path = [[MXEXmlArrayPath alloc] initWithParentNodePath:@"a.b"
                                                                collectRelativePath:MXEXmlChildNode(@"a.c")];
            expect([path.collectRelativePath isKindOfClass:MXEXmlChildNodePath.class]).to(equal(YES));
            expect(((MXEXmlChildNodePath*)path.collectRelativePath).nodeName).to(equal(@"c"));
        });

        it(@"return a instance, if collectRelativePath is string", ^{
            MXEXmlArrayPath* path = [[MXEXmlArrayPath alloc] initWithParentNodePath:@"a.b"
                                                                collectRelativePath:@"c.d"];
            expect([path.collectRelativePath isKindOfClass:MXEXmlPath.class]).to(equal(YES));
            expect(path.collectRelativePath.separatedPath.count).to(equal(2));
            expect(path.collectRelativePath.separatedPath[0]).to(equal(@"c"));
            expect(path.collectRelativePath.separatedPath[1]).to(equal(@"d"));
        });
    });

    describe(@"copyWithZone:", ^{
        it(@"can copy properties", ^{
            MXEXmlArrayPath* path = [MXEXmlArrayPath pathWithParentNodePath:@"a.b" collectRelativePath:@"c.d"];
            MXEXmlArrayPath* copyPath = [path copy];

            expect(path != copyPath).to(equal(YES));
            expect(path.collectRelativePath != copyPath.collectRelativePath).to(equal(YES));
            expect(path.separatedPath != copyPath.separatedPath).to(equal(YES));
        });
    });

    describe(@"description", ^{
        it(@"is correct description", ^{
            MXEXmlArrayPath* path = MXEXmlArray(@"a.b", @"c");
            expect([path description]).to(equal(@"MXEXmlArray(@\"a.b\", MXEXmlPath(@\"c\"))"));
        });
    });

    describe(@"getValueBlocks", ^{
        MXEXmlArrayPath* path = [MXEXmlArrayPath pathWithParentNodePath:@"a.b" collectRelativePath:@"c.d"];

        MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
        MXEMutableXmlNode* c1 = [[MXEMutableXmlNode alloc] initWithElementName:@"c"];
        MXEMutableXmlNode* c2 = [[MXEMutableXmlNode alloc] initWithElementName:@"c"];

        node.children = @[ c1, c2 ];

        it(@"return array of value and MXEXmlPath # getValueBlocks is called", ^{
            MXEMutableXmlNode* d1 = [[MXEMutableXmlNode alloc] initWithElementName:@"d"];
            MXEMutableXmlNode* d2 = [[MXEMutableXmlNode alloc] initWithElementName:@"d"];
            c1.children = @[ d1 ];
            c2.children = @[ d2 ];
            d1.children = @"d1";
            d2.children = @"d2";

            id mock = OCMPartialMock(path.collectRelativePath);
            __block int getValueBlocksCounter = 0;
            OCMStub([mock getValueBlocks])
                .andDo(^(NSInvocation* invocation) {
                    getValueBlocksCounter++;
                })
                .andForwardToRealObject();

            NSArray* result = [path getValueBlocks](node);
            expect(result.count).to(equal(2));
            expect(result[0]).to(equal(@"d1"));
            expect(result[1]).to(equal(@"d2"));

            expect(getValueBlocksCounter).to(equal(2));
            [mock stopMocking];
        });

        it(@"return nil, if it is not found", ^{
            c1.children = @"value";
            c2.children = @[ [[MXEXmlNode alloc] initWithElementName:@"e"] ];

            expect([path getValueBlocks](node)).to(beNil());
        });

        it(@"return nil, if children isn't exist", ^{
            MXEMutableXmlNode* root = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
            expect([path getValueBlocks](root)).to(beNil());

            root.children = @"value";
            expect([path getValueBlocks](root)).to(beNil());
        });
    });

    describe(@"setValueBlocks", ^{
        MXEXmlArrayPath* path = [MXEXmlArrayPath pathWithParentNodePath:@"a.b" collectRelativePath:@"c.d"];

        it(@"return NO, if value isn't array", ^{
            MXEMutableXmlNode* root = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
            expect([path setValueBlocks](root, @"new")).to(equal(NO));
        });

        it(@"return YES and update, if value is array", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
            MXEMutableXmlNode* c1 = [[MXEMutableXmlNode alloc] initWithElementName:@"c"];
            MXEMutableXmlNode* c2 = [[MXEMutableXmlNode alloc] initWithElementName:@"c"];
            MXEMutableXmlNode* d1 = [[MXEMutableXmlNode alloc] initWithElementName:@"d"];
            MXEMutableXmlNode* d2 = [[MXEMutableXmlNode alloc] initWithElementName:@"d"];

            node.children = @[ c1, c2 ];
            c1.children = @[ d1 ];
            c2.children = @[ d2 ];
            d1.children = @"d1";
            d2.children = @"d2";

            NSArray* expectList = @[ @"new1", @"new2", @"new3" ];
            expect([path setValueBlocks](node, expectList)).to(equal(YES));
            expect([node.children count]).to(equal(3));

            for (int i = 0; i < expectList.count; i++) {
                expect([((MXEXmlNode*)node.children[i]).children count]).to(equal(1));
                expect([((MXEXmlNode*)node.children[i]).children[0] children]).to(equal(expectList[i]));
            }

            expectList = @[ @"feature1", @"feature2" ];
            expect([path setValueBlocks](node, expectList)).to(equal(YES));
            expect([node.children count]).to(equal(3));

            for (int i = 0; i < expectList.count; i++) {
                expect([((MXEXmlNode*)node.children[i]).children count]).to(equal(1));
                expect([((MXEXmlNode*)node.children[i]).children[0] children]).to(equal(expectList[i]));
            }
            expect([((MXEXmlNode*)node.children[2]).children[0] children]).to(beNil());
        });

        it(@"does not change other elements", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
            MXEXmlArrayPath* path1 = [MXEXmlArrayPath pathWithParentNodePath:@"a.b" collectRelativePath:@"c.d"];
            expect([path1 setValueBlocks](node, @[ @"d1", @"d2" ])).to(equal(YES));

            MXEXmlArrayPath* path2 = [MXEXmlArrayPath pathWithParentNodePath:@"a.b" collectRelativePath:@"c.e"];
            expect([path2 setValueBlocks](node, @[ @"e1", @"e2", @"e3" ])).to(equal(YES));

            expect([node toString]).to(equal(@"<b>"
                                             @"<c><d>d1</d><e>e1</e></c>"
                                             @"<c><d>d2</d><e>e2</e></c>"
                                             @"<c><e>e3</e></c>"
                                             @"</b>"));
        });
    });
}
QuickSpecEnd
