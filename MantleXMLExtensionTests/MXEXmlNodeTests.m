//
//  MXEXmlNodeTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXEXmlNode.h"

QuickSpecBegin(MXEXmlNodeTests)

describe(@"toString", ^{

    it(@"attributes is exist, children isn't exist", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        root.attributes = @{@"key1":@"value1", @"key2":@"value2"};
        expect([root toString]).to(equal(@"<object key1=\"value1\" key2=\"value2\" />"));
    });

    it(@"The attribute values escaped", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        root.attributes = @{@"key":@"escape string is \"'<>&"};
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
        root.attributes = @{@"key1":@"value1", @"key2":@"value2"};
        MXEXmlNode* child = [[MXEXmlNode alloc] initWithElementName:@"2nd"];
        child.attributes = @{@"key1":@"value1", @"key2":@"value2"};
        root.children = @[ [[MXEXmlNode alloc] initWithElementName:@"1st"],
                           child,
                           [[MXEXmlNode alloc] initWithElementName:@"3rd"]];
        expect([root toString]).to(equal(@"<object key1=\"value1\" key2=\"value2\">"
                                         @"<1st />"
                                         @"<2nd key1=\"value1\" key2=\"value2\" />"
                                         @"<3rd />"
                                         @"</object>"));
    });
});

describe(@"-isEqual:", ^{

    it(@"isEqual: is correct. Attribute depend on the order", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        a.attributes = [NSMutableDictionary dictionary];
        ((NSMutableDictionary*)a.attributes)[@"key1"] = @"value1";
        ((NSMutableDictionary*)a.attributes)[@"key2"] = @"value2";
        a.children   = @"hoge";

        MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"];
        ((NSMutableDictionary*)a.attributes)[@"key2"] = @"value2";
        ((NSMutableDictionary*)a.attributes)[@"key1"] = @"value1";
        b.children   = @"hoge";
        expect(a).notTo(equal(b));
    });

    it(@"Children depend on the order", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        a.children = @[[[MXEXmlNode alloc] initWithElementName:@"child1"],
                       [[MXEXmlNode alloc] initWithElementName:@"child2"]];
        MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"];
        b.children = @[[[MXEXmlNode alloc] initWithElementName:@"child2"],
                       [[MXEXmlNode alloc] initWithElementName:@"child1"]];
        expect(a).notTo(equal(b));
    });

    it(@"Attribute and children are different", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        a.attributes = @{@"key1":@"value1", @"key2":@"value2"};

        MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"object"];

        MXEXmlNode* key1 = [[MXEXmlNode alloc] initWithElementName:@"key1"];
        key1.children = @"value1";
        MXEXmlNode* key2 = [[MXEXmlNode alloc] initWithElementName:@"key2"];
        key2.children = @"value2";

        b.children = @[ key1, key2 ];
        expect(a).notTo(equal(b));
    });
});

describe(@"initWithKeyPath:", ^{

    it(@"string path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithKeyPath:@"a.b.c"];
        expect([a toString]).to(equal(@"<a><b><c /></b></a>"));
    });

    it(@"array path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithKeyPath:@[@"a", @"b", @"c"]];
        expect([a toString]).to(equal(@"<a><b><c /></b></a>"));
    });

    it(@"attribute path is unsupported", ^{
        expect([[MXEXmlNode alloc] initWithKeyPath:MXEXmlAttribute(@"a.b", @"c")]).to(raiseException());
    });

    it(@"duplicate path is unsupported", ^{
        expect([[MXEXmlNode alloc] initWithKeyPath:MXEXmlDuplicateNodes(@"a.b", @"c")]).to(raiseException());
    });
});

describe(@"initWithKeyPath:value:", ^{

    it(@"string path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithKeyPath:@"a.b.c" value:@"value"];
        expect([a toString]).to(equal(@"<a><b><c>value</c></b></a>"));
    });

    it(@"array path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithKeyPath:@[@"a", @"b", @"c"] value:@"value"];
        expect([a toString]).to(equal(@"<a><b><c>value</c></b></a>"));
    });

    it(@"attribute path is unsupported", ^{
        expect([[MXEXmlNode alloc] initWithKeyPath:MXEXmlAttribute(@"a.b", @"c") value:@"value"])
        .to(raiseException());
    });

    it(@"duplicate path is unsupported", ^{
        expect([[MXEXmlNode alloc] initWithKeyPath:MXEXmlDuplicateNodes(@"a.b", @"c") value:@"value"])
        .to(raiseException());
    });
});

describe(@"initWithKeyPath:blocks:", ^{

    it(@"string path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithKeyPath:@"a.b.c"
                                                     blocks:^(MXEXmlNode* _Nonnull node) {
                                                         node.children = @"value";
                                                     }];
        expect([a toString]).to(equal(@"<a><b><c>value</c></b></a>"));
    });

    it(@"array path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithKeyPath:@[@"a", @"b", @"c"]
                                                     blocks:^(MXEXmlNode* _Nonnull node) {
                                                         node.attributes = @{@"key":@"value"};
                                                     }];
        expect([a toString]).to(equal(@"<a><b><c key=\"value\" /></b></a>"));
    });

    it(@"attribute path is unsupported", ^{
        expect([[MXEXmlNode alloc] initWithKeyPath:MXEXmlAttribute(@"a.b", @"c") blocks:nil])
        .to(raiseException());
    });

    it(@"duplicate path is unsupported", ^{
        expect([[MXEXmlNode alloc] initWithKeyPath:MXEXmlDuplicateNodes(@"a.b", @"c") blocks:nil])
        .to(raiseException());
    });
});

describe(@"-setChild:forKeyPath: and -getChildForKeyPath:", ^{

    it(@"string path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        [a setChild:@"value" forKeyPath:@"a.b"];
        [a setChild:@"value1" forKeyPath:@"a.c"];
        [a setChild:@"value2" forKeyPath:@"a.c"];
        [a setChild:@"value" forKeyPath:@"b"];
        expect([a toString]).to(equal(@"<object><a><b>value</b><c>value2</c></a><b>value</b></object>"));

        expect([a getChildForKeyPath:@"a.b"]).to(equal(@"value"));
        expect([a getChildForKeyPath:@"a.c"]).to(equal(@"value2"));
        expect([a getChildForKeyPath:@"e.g"]).to(beNil());

        id children = [a getChildForKeyPath:@"a"];
        expect([children isKindOfClass:NSArray.class]).to(equal(YES));
        expect([children count]).to(equal(2));
        expect([children[0] toString]).to(equal(@"<b>value</b>"));
        expect([children[1] toString]).to(equal(@"<c>value2</c>"));
    });

    it(@"array path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        [a setChild:@"value" forKeyPath:@[@"a", @"b"]];
        [a setChild:@"value1" forKeyPath:@[@"a", @"c"]];
        [a setChild:@"value2" forKeyPath:@[@"a", @"c"]];
        [a setChild:@"value" forKeyPath:@[@"b"]];
        expect([a toString]).to(equal(@"<object><a><b>value</b><c>value2</c></a><b>value</b></object>"));

        expect([a getChildForKeyPath:@[@"a", @"b"]]).to(equal(@"value"));
        expect([a getChildForKeyPath:@[@"a", @"c"]]).to(equal(@"value2"));
        expect([a getChildForKeyPath:@[@"e", @"g"]]).to(beNil());

        id children = [a getChildForKeyPath:@"a"];
        expect([children isKindOfClass:NSArray.class]).to(equal(YES));
        expect([children count]).to(equal(2));
        expect([children[0] toString]).to(equal(@"<b>value</b>"));
        expect([children[1] toString]).to(equal(@"<c>value2</c>"));
    });

    it(@"empty path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        [a setChild:@"value" forKeyPath:@""];
        expect([a toString]).to(equal(@"<object>value</object>"));

        [a setChild:@"value2" forKeyPath:@"."];
        expect([a toString]).to(equal(@"<object>value2</object>"));

        [a setChild:@"value3" forKeyPath:@[]];
        expect([a toString]).to(equal(@"<object>value3</object>"));

        expect([a getChildForKeyPath:@""]).to(equal(@"value3"));
        expect([a getChildForKeyPath:@"."]).to(equal(@"value3"));
        expect([a getChildForKeyPath:@[]]).to(equal(@"value3"));
    });

    it(@"attribute path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        [a setChild:@"value1" forKeyPath:MXEXmlAttribute(@"a.b", @"key1")];
        [a setChild:@"value2" forKeyPath:MXEXmlAttribute(@"a.b", @"key2")];
        [a setChild:@"value3" forKeyPath:MXEXmlAttribute(@"a.b", @"key2")];
        expect([a toString]).to(equal(@"<object><a><b key1=\"value1\" key2=\"value3\" /></a></object>"));

        expect([a getChildForKeyPath:MXEXmlAttribute(@"a.b", @"key1")]).to(equal(@"value1"));
        expect([a getChildForKeyPath:MXEXmlAttribute(@"a.b", @"key2")]).to(equal(@"value3"));
    });

    it(@"root attribute", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        [a setChild:@"value1" forKeyPath:MXEXmlAttribute(@"", @"key1")];
        [a setChild:@"value2" forKeyPath:MXEXmlAttribute(@".", @"key2")];
        [a setChild:@"value3" forKeyPath:MXEXmlAttribute(@"", @".")];
        expect([a toString]).to(equal(@"<object key1=\"value1\" .=\"value3\" key2=\"value2\" />"));

        expect([a getChildForKeyPath:MXEXmlAttribute(@"", @"key1")]).to(equal(@"value1"));
        expect([a getChildForKeyPath:MXEXmlAttribute(@".", @"key2")]).to(equal(@"value2"));
    });

    it(@"duplicate path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        [a setChild:@"value1" forKeyPath:MXEXmlDuplicateNodes(@"a.b", @"c.d")];
        [a setChild:@"value2" forKeyPath:MXEXmlDuplicateNodes(@"a.b", @"c.d")];
        [a setChild:@"value3" forKeyPath:MXEXmlDuplicateNodes(@"a.b", @"e")];
        expect([a toString]).to(equal(@"<object><a><b>"
                                      @"<c><d>value1</d></c>"
                                      @"<c><d>value2</d></c>"
                                      @"<e>value3</e>"
                                      @"</b></a></object>"));

        id nodes = [a getChildForKeyPath:MXEXmlDuplicateNodes(@"a.b", @"c.d")];
        expect([nodes isKindOfClass:NSArray.class]);
        expect([nodes count]).to(equal(2));
        expect(nodes[0]).to(equal(@"value1"));
        expect(nodes[1]).to(equal(@"value2"));

        nodes = [a getChildForKeyPath:MXEXmlDuplicateNodes(@"a.b", @"e")];
        expect([nodes isKindOfClass:NSArray.class]);
        expect([nodes count]).to(equal(1));
        expect(nodes[0]).to(equal(@"value3"));
    });

    it(@"root duplicate path", ^{
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"object"];
        [a setChild:@"value1" forKeyPath:MXEXmlDuplicateNodes(@"", @"a.b")];
        [a setChild:@"value2" forKeyPath:MXEXmlDuplicateNodes(@".", @"a.c")];
        [a setChild:@"value3" forKeyPath:MXEXmlDuplicateNodes(@"", @".")];
        expect([a toString]).to(equal(@"<object>"
                                      @"<a><b>value1</b></a>"
                                      @"<a><c>value2</c></a>"
                                      @"</object>"));

        id nodes = [a getChildForKeyPath:MXEXmlDuplicateNodes(@"", @"a.b")];
        expect([nodes isKindOfClass:NSArray.class]);
        expect([nodes count]).to(equal(1));
        expect(nodes[0]).to(equal(@"value1"));

        nodes = [a getChildForKeyPath:MXEXmlDuplicateNodes(@".", @"a.c")];
        expect([nodes isKindOfClass:NSArray.class]);
        expect([nodes count]).to(equal(1));
        expect(nodes[0]).to(equal(@"value2"));
    });
});

QuickSpecEnd
