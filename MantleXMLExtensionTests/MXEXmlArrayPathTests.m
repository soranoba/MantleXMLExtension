//
//  MXEXmlArrayPathTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/23.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXEXmlNode.h"
#import "MXEXmlArrayPath+Private.h"

QuickSpecBegin(MXEXmlArrayPathTests)

describe(@"getValueBlocks", ^{

    it(@"", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"object"];
        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"user"];
        a.children = @"user1";
        MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"user"];
        b.children = @"user2";
        MXEXmlNode* c = [[MXEXmlNode alloc] initWithElementName:@"user"];
        c.children = @"user3";
        node.children = @[a,b,c];

        NSArray* array = MXEXmlArray(@"object", @"user").getValueBlocks(node);
        expect(array.count).to(equal(3));
        expect(array[0]).to(equal(@"user1"));
        expect(array[1]).to(equal(@"user2"));
        expect(array[2]).to(equal(@"user3"));
    });

    it(@"", ^{
        MXEXmlNode* node1 = [[MXEXmlNode alloc] initWithElementName:@"x"];
        MXEXmlNode* node2 = [[MXEXmlNode alloc] initWithElementName:@"y"];
        MXEXmlNode* node3 = [[MXEXmlNode alloc] initWithElementName:@"y"];
        node1.children = @[node2, node3];

        MXEXmlNode* a = [[MXEXmlNode alloc] initWithElementName:@"user"];
        a.children = @"user1";
        MXEXmlNode* b = [[MXEXmlNode alloc] initWithElementName:@"user"];
        b.children = @"user2";
        MXEXmlNode* c = [[MXEXmlNode alloc] initWithElementName:@"user"];
        c.children = @"user3";
        node2.children = @[a,c];
        node3.children = @[b];

        NSArray* array = MXEXmlArray(@"x.y", @"user").getValueBlocks(node1);
        expect(array.count).to(equal(2));
        expect(array[0]).to(equal(@"user1"));
        expect(array[1]).to(equal(@"user3"));
    });
});

describe(@"setValueBlocks", ^{

});

QuickSpecEnd
