//
//  MXEXmlAttributePathTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/27.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlAttributePath+Private.h"
#import "MXEXmlNode.h"

QuickSpecBegin(MXEXmlAttributePathTests)
{
    describe(@"initWithNodePath:attributeKey:", ^{
        it(@"failed, if attribute key's length is 0", ^{
            expect([[MXEXmlAttributePath alloc] initWithNodePath:@"a.b" attributeKey:@""]).to(raiseException());
        });

        it(@"success, if attribute key's length longer than 0", ^{
            MXEXmlAttributePath* path = [[MXEXmlAttributePath alloc] initWithNodePath:@"a.b" attributeKey:@"key"];
            expect(path.attributeKey).to(equal(@"key"));
        });
    });

    describe(@"copyWithZone:", ^{
        it(@"can copy properties", ^{
            MXEXmlAttributePath* path = [MXEXmlAttributePath pathWithNodePath:@"a.b" attributeKey:@"key"];
            MXEXmlAttributePath* copyPath = [path copy];

            expect(path != copyPath).to(equal(YES));

            path.attributeKey = @"new";
            expect(path.attributeKey).notTo(equal(copyPath.attributeKey));

            expect(path.separatedPath != copyPath.separatedPath).to(equal(YES));
        });
    });

    describe(@"description", ^{
        it(@"is correct description", ^{
            MXEXmlAttributePath* path = MXEXmlAttribute(@"a.b", @"c");
            expect([path description]).to(equal(@"MXEXmlAttribute(@\"a.b\", @\"c\")"));
        });
    });

    describe(@"getValueBlocks", ^{
        MXEXmlAttributePath* path = [MXEXmlAttributePath pathWithNodePath:@"a.b" attributeKey:@"key"];

        it(@"return attribute value, if attribute found", ^{
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"b"
                                                            attributes:@{ @"key" : @"value",
                                                                          @"key2" : @"value2" }
                                                              children:nil];
            expect([path getValueBlocks](node)).to(equal(@"value"));
        });

        it(@"return nil, if attribute isn't found", ^{
            MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"b"
                                                            attributes:@{ @"key1" : @"value",
                                                                          @"key2" : @"value2" }
                                                              children:nil];
            expect([path getValueBlocks](node)).to(beNil());
        });

        it(@"return nil, if attributes is empty", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"];
            expect([path getValueBlocks](node)).to(beNil());
        });
    });

    describe(@"setValueBlocks", ^{
        MXEXmlAttributePath* path = [MXEXmlAttributePath pathWithNodePath:@"a.b" attributeKey:@"key"];

        it(@"return NO and attributes didn't change, if value isn't string", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"
                                                                          attributes:@{ @"key" : @"value",
                                                                                        @"key2" : @"value2" }
                                                                            children:nil];

            expect([path setValueBlocks](node, @1)).to(equal(NO));
            expect([node.attributes count]).to(equal(2));
            expect(node.attributes[@"key"]).to(equal(@"value"));
            expect(node.attributes[@"key2"]).to(equal(@"value2"));
        });

        it(@"return YES and delete a attribute, if value is nil", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"
                                                                          attributes:@{ @"key" : @"value",
                                                                                        @"key2" : @"value2" }
                                                                            children:nil];

            expect([path setValueBlocks](node, nil)).to(equal(YES));
            expect([node.attributes count]).to(equal(1));
            expect(node.attributes[@"key"]).to(beNil());
            expect(node.attributes[@"key2"]).to(equal(@"value2"));
        });

        it(@"return YES and update attribute, if value is empty string", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"
                                                                          attributes:@{ @"key" : @"value",
                                                                                        @"key2" : @"value2" }
                                                                            children:nil];

            expect([path setValueBlocks](node, @"")).to(equal(YES));
            expect([node.attributes count]).to(equal(2));
            expect(node.attributes[@"key"]).to(equal(@""));
            expect(node.attributes[@"key2"]).to(equal(@"value2"));
        });

        it(@"return YES and update attribute, if value is string", ^{
            MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"b"
                                                                          attributes:@{ @"key" : @"value",
                                                                                        @"key2" : @"value2" }
                                                                            children:nil];

            expect([path setValueBlocks](node, @"new")).to(equal(YES));
            expect([node.attributes count]).to(equal(2));
            expect(node.attributes[@"key"]).to(equal(@"new"));
            expect(node.attributes[@"key2"]).to(equal(@"value2"));
        });
    });
}
QuickSpecEnd
