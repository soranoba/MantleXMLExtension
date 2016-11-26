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

describe(@"getValueBlocks", ^{
    MXEXmlArrayPath* path = [MXEXmlArrayPath pathWithParentNodePath:@"a.b" collectRelativePath:@"c.d"];

    MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"b"];
    MXEXmlNode* c1 = [[MXEXmlNode alloc] initWithElementName:@"c"];
    MXEXmlNode* c2 = [[MXEXmlNode alloc] initWithElementName:@"c"];

    node.children = @[ c1, c2 ];

    it(@"return array of value and MXEXmlPath # getValueBlocks is called", ^{
        MXEXmlNode* d1 = [[MXEXmlNode alloc] initWithElementName:@"d"];
        MXEXmlNode* d2 = [[MXEXmlNode alloc] initWithElementName:@"d"];
        c1.children = @[ d1 ];
        c2.children = @[ d2 ];
        d1.children = @"d1";
        d2.children = @"d2";

        id mock = OCMPartialMock(path.collectRelativePath);
        __block int getValueBlocksCounter = 0;
        OCMStub([mock getValueBlocks]).andDo(^(NSInvocation* invocation) {
            getValueBlocksCounter++;
        }).andForwardToRealObject();

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
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"b"];
        expect([path getValueBlocks](root)).to(beNil());

        root.children = @"value";
        expect([path getValueBlocks](root)).to(beNil());
    });
});

describe(@"setValueBlocks", ^{
    MXEXmlArrayPath* path = [MXEXmlArrayPath pathWithParentNodePath:@"a.b" collectRelativePath:@"c.d"];

    it(@"return NO, if children isn't exist", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"b"];
        expect([path setValueBlocks](root, @"new")).to(equal(NO));

        root.children = @"value";
        expect([path setValueBlocks](root, @"new")).to(equal(NO));
    });

    it(@"return YES and update, if it is found", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"b"];
        MXEXmlNode* c1 = [[MXEXmlNode alloc] initWithElementName:@"c"];
        MXEXmlNode* c2 = [[MXEXmlNode alloc] initWithElementName:@"c"];
        MXEXmlNode* d1 = [[MXEXmlNode alloc] initWithElementName:@"d"];
        MXEXmlNode* d2 = [[MXEXmlNode alloc] initWithElementName:@"d"];

        node.children = @[ c1, c2 ];
        c1.children = @[ d1 ];
        c2.children = @[ d2 ];
        d1.children = @"d1";
        d2.children = @"d2";

        expect([path setValueBlocks](node, @[@"new1", @"new2", @"new3"])).to(equal(YES));
    });
});

QuickSpecEnd
