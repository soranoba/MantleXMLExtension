//
//  MXEXmlPathTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/26.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"
#import "MXEXmlPath+Private.h"

QuickSpecBegin(MXEXmlPathTests)
{
    describe(@"separateNodePath:", ^{
        it(@"Null character is excluded", ^{
            NSArray* array1 = [MXEXmlPath separateNodePath:@".."];
            expect(array1.count).to(equal(0));

            NSArray* array2 = [MXEXmlPath separateNodePath:@".a..b."];
            expect(array2.count).to(equal(2));
            expect(array2[0]).to(equal(@"a"));
            expect(array2[1]).to(equal(@"b"));
        });
    });

    describe(@"copyWithZone:", ^{
        it(@"Properties was copied", ^{
            MXEXmlPath* path1 = [MXEXmlPath pathWithNodePath:@"a.b"];
            MXEXmlPath* path2 = [path1 copy];

            expect(path1).notTo(equal(path2));
            expect(path1.separatedPath != path2.separatedPath).to(equal(YES));
            expect(path1.separatedPath.count).to(equal(path2.separatedPath.count));
            for (int i = 0; i < path1.separatedPath.count; i++) {
                expect(path1.separatedPath[i]).to(equal(path2.separatedPath[i]));
            }
        });
    });

    describe(@"description", ^{
        it(@"is correct description", ^{
            MXEXmlPath* path = [MXEXmlPath pathWithNodePath:@"a.b"];
            expect([path description]).to(equal(@"MXEXmlPath(@\"a.b\")"));
        });
    });

    describe(@"getValueBlocks", ^{
        MXEXmlPath* path = [MXEXmlPath pathWithNodePath:@"a.b"];

        it(@"return nil, if children is nil", ^{
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"b"];
            expect([path getValueBlocks](node)).to(beNil());
        });

        it(@"return nil, if children are array of MXEXmlNode", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
            [node addChild:[[MXEMutableXmlNode alloc] initWithElementName:@"c"]];
            expect([path getValueBlocks](node)).to(beNil());
        });

        it(@"can get value", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
            node.value = @"value";
            expect([path getValueBlocks](node)).to(equal(@"value"));
        });
    });

    describe(@"setValueBlocks", ^{
        MXEXmlPath* path = [MXEXmlPath pathWithNodePath:@"a.b"];

        it(@"return NO and children didn't change, if value isn't string", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
            node.value = @"old";

            expect([path setValueBlocks](node, @2)).to(equal(NO));
            expect(node.value).to(equal(@"old"));
        });

        it(@"return YES and delete children, if value is nil", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
            node.value = @"old";

            expect([path setValueBlocks](node, nil)).to(equal(YES));
            expect(node.children).to(beNil());

            [node addChild:[[MXEXmlNode alloc] initWithElementName:@"c"]];
            expect([path setValueBlocks](node, nil)).to(equal(YES));
            expect(node.children).to(beNil());
        });

        it(@"return YES and update children, if value is string", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
            [node addChild:[[MXEXmlNode alloc] initWithElementName:@"c"]];

            expect([path setValueBlocks](node, @"new")).to(equal(YES));
            expect(node.value).to(equal(@"new"));
        });
    });
}
QuickSpecEnd
