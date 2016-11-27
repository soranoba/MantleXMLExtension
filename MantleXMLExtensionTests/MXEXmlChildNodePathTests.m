//
//  MXEXmlChildNodePathTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/27.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlChildNodePath+Private.h"
#import "MXEXmlNode.h"

QuickSpecBegin(MXEXmlChildNodePathTests)

    describe(@"copyWithZone:", ^{
        it(@"can copy properties", ^{
            MXEXmlChildNodePath* path = [MXEXmlChildNodePath pathWithNodePath:@"a.b"];
            MXEXmlChildNodePath* copyPath = [path copy];

            expect(path != copyPath).to(equal(YES));

            path.nodeName = @"new";
            expect(path.nodeName).notTo(equal(copyPath.nodeName));

            expect(path.separatedPath != copyPath.separatedPath).to(equal(YES));
        });
    });

describe(@"initWithNodePath:", ^{
    it(@"failed, if input path is empty", ^{
        expect([[MXEXmlChildNodePath alloc] initWithNodePath:@"."]).to(raiseException());
        expect([[MXEXmlChildNodePath alloc] initWithNodePath:@""]).to(raiseException());
    });

    it(@"separatedPath specify the parent node", ^{
        MXEXmlChildNodePath* path = [MXEXmlChildNodePath pathWithNodePath:@"a.b.c"];
        expect(path.separatedPath.count).to(equal(2));
        expect(path.separatedPath[0]).to(equal(@"a"));
        expect(path.separatedPath[1]).to(equal(@"b"));

        expect(path.nodeName).to(equal(@"c"));
    });
});

describe(@"getValueBlocks", ^{
    MXEXmlChildNodePath* path = [MXEXmlChildNodePath pathWithNodePath:@"a.b"];

    it(@"called MXEXmlNode # lookupChild:, and return child", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"a"];
        node.children = @[ [[MXEXmlNode alloc] initWithElementName:@"b"] ];

        id mock = OCMPartialMock(node);
        OCMExpect([mock lookupChild:@"b"]).andForwardToRealObject();

        MXEXmlNode* child = [path getValueBlocks](node);
        expect(child.elementName).to(equal(@"b"));

        [mock verify];
    });

    it(@"return nil, if children is nil", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"a"];
        expect([path getValueBlocks](node)).to(beNil());
    });

    it(@"return nil, if children is string", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"a"];
        node.children = @"value";
        expect([path getValueBlocks](node)).to(beNil());
    });

    it(@"return nil, if it specify anything other than children", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"a"];
        node.children = @[ [[MXEXmlNode alloc] initWithElementName:@"c"] ];
        expect([path getValueBlocks](node)).to(beNil());
    });
});

describe(@"setValueBlocks", ^{
    MXEXmlPath* path = [MXEXmlChildNodePath pathWithNodePath:@"a.b"];

    it(@"return NO and children didn't change, if value isn't MXEXmlNode", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"a"];
        node.children = @"old";

        expect([path setValueBlocks](node, @"new")).to(equal(NO));
        expect(node.children).to(equal(@"old"));
    });

    it(@"return YES and delete the child, if value is nil", ^{
        MXEXmlNode* b1 = [[MXEXmlNode alloc] initWithElementName:@"b"];
        b1.children = @"b1";
        MXEXmlNode* b2 = [[MXEXmlNode alloc] initWithElementName:@"b"];
        b2.children = @"b2";

        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"a"];
        node.children = @[ b1, b2 ];

        expect([path setValueBlocks](node, nil)).to(equal(YES));
        expect([node.children count]).to(equal(1));
        expect(((MXEXmlNode*)node.children[0]).children).to(equal(@"b2"));
    });

    it(@"return YES and append child, if value is MXEXmlNode and child is not found", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"a"];
        node.children = @[ [[MXEXmlNode alloc] initWithElementName:@"c"] ];

        expect([path setValueBlocks](node, [[MXEXmlNode alloc] initWithElementName:@"b"])).to(equal(YES));
        expect([node.children count]).to(equal(2));
        expect(((MXEXmlNode*)node.children[0]).elementName).to(equal(@"c"));
        expect(((MXEXmlNode*)node.children[1]).elementName).to(equal(@"b"));
    });

    it(@"return YES and update child, if value is MXEXmlNode and child is found", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"a"];
        node.children = @[ [[MXEXmlNode alloc] initWithElementName:@"b"],
                           [[MXEXmlNode alloc] initWithElementName:@"c"] ];

        MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"b"];
        b.children = @"new";

        expect([path setValueBlocks](node, b)).to(equal(YES));
        expect([node.children count]).to(equal(2));
        expect(((MXEXmlNode*)node.children[0]).elementName).to(equal(@"b"));
        expect(((MXEXmlNode*)node.children[1]).elementName).to(equal(@"c"));
        expect(((MXEXmlNode*)node.children[0]).children).to(equal(@"new"));
    });

    it(@"update child and elementName is changed, if value's elementName isn't same", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"a"];
        node.children = @[ [[MXEXmlNode alloc] initWithElementName:@"b"],
                           [[MXEXmlNode alloc] initWithElementName:@"c"] ];

        MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"d"];
        b.children = @"new";

        expect([path setValueBlocks](node, b)).to(equal(YES));
        expect([node.children count]).to(equal(2));
        expect(((MXEXmlNode*)node.children[0]).elementName).to(equal(@"b"));
        expect(((MXEXmlNode*)node.children[1]).elementName).to(equal(@"c"));
        expect(((MXEXmlNode*)node.children[0]).children).to(equal(@"new"));
    });
});

QuickSpecEnd
