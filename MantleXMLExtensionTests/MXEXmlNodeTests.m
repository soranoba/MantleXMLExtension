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

    it(@"The attribute values are backslash escaped", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        root.attributes = @{@"key":@"escape is \"OK\""};
        expect([root toString]).to(equal(@"<object key=\"escape is \\\"OK\\\"\" />"));
    });

    it(@"attributes isn't exist, children isn't exist", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        expect([root toString]).to(equal(@"<object />"));
    });

    it(@"attributes isn't exist, children is exist", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        root.children = [@[ @"1st", [[MXEXmlNode alloc] initWithElementName:@"2nd"], @"3rd"] mutableCopy];
        expect([root toString]).to(equal(@"<object>1st<2nd />3rd</object>"));
    });

    it(@"attribute is exist, children is exist", ^{
        MXEXmlNode* root = [[MXEXmlNode alloc] initWithElementName:@"object"];
        root.attributes = @{@"key1":@"value1", @"key2":@"value2"};
        MXEXmlNode* child = [[MXEXmlNode alloc] initWithElementName:@"2nd"];
        child.attributes = @{@"key1":@"value1", @"key2":@"value2"};
        root.children = [@[ @"1st", child, @"3rd"] mutableCopy];
        expect([root toString]).to(equal(@"<object key1=\"value1\" key2=\"value2\">"
                                         @"1st<2nd key1=\"value1\" key2=\"value2\" />3rd"
                                         @"</object>"));
    });
});

QuickSpecEnd
