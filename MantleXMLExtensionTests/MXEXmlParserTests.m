//
//  MXEXmlParserTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/25.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlParser.h"

@interface MXEXmlParser ()
+ (NSStringEncoding)xmlDeclarationToEncoding:(NSString* _Nonnull)xmlDeclaration
                                       error:(NSError* _Nullable* _Nullable)error;
@end

QuickSpecBegin(MXEXmlParserTests)
{
    describe(@"xmlNodeWithData:error:", ^{
        it(@"can parse value, child nodes and attributes", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                               @"<response status=\"OK\">\n"
                               @"  <user>\n"
                               @"    <id>1</id>\n"
                               @"  </user>\n"
                               @"  <user>\n"
                               @"    <id>2</id>\n"
                               @"  </user>\n"
                               @"</response>";

            MXEXmlNode* userId1 = [[MXEXmlNode alloc] initWithElementName:@"id"
                                                               attributes:nil
                                                                    value:@"1"];
            MXEXmlNode* userId2 = [[MXEXmlNode alloc] initWithElementName:@"id"
                                                               attributes:nil
                                                                    value:@"2"];
            MXEXmlNode* user1 = [[MXEXmlNode alloc] initWithElementName:@"user"
                                                             attributes:nil
                                                               children:@[ userId1 ]];
            MXEXmlNode* user2 = [[MXEXmlNode alloc] initWithElementName:@"user"
                                                             attributes:nil
                                                               children:@[ userId2 ]];
            MXEXmlNode* expectedObj = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                                   attributes:@{ @"status" : @"OK" }
                                                                     children:@[ user1, user2 ]];

            __block MXEXmlNode* node;
            __block NSError* error = nil;
            expect(node = [MXEXmlParser xmlNodeWithData:[xmlStr dataUsingEncoding:NSUTF8StringEncoding] error:&error])
                .to(equal(expectedObj));
            expect(error).to(beNil());
        });

        it(@"ignore text, when the node have mixed child nodes and text", ^{
            NSString* xmlStr1 = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                                @"<response>\n"
                                @"  <child>value</child>\n"
                                @"  Hello world!!\n"
                                @"  <child>value</child>\n"
                                @"</response>";

            NSString* xmlStr2 = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                                @"<response>\n"
                                @"  Hello world!!\n"
                                @"  <child>value</child>\n"
                                @"  Hello world!!\n"
                                @"</response>";

            MXEXmlNode* childNode = [[MXEXmlNode alloc] initWithElementName:@"child"
                                                                 attributes:nil
                                                                      value:@"value"];
            MXEXmlNode* expectedObj1 = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                                    attributes:nil
                                                                      children:@[ childNode, childNode ]];
            MXEXmlNode* expectedObj2 = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                                    attributes:nil
                                                                      children:@[ childNode ]];

            __block MXEXmlNode* node;
            __block NSError* error = nil;
            expect(node = [MXEXmlParser xmlNodeWithData:[xmlStr1 dataUsingEncoding:NSUTF8StringEncoding] error:&error])
                .to(equal(expectedObj1));
            expect(error).to(beNil());

            node = nil;
            error = nil;
            expect(node = [MXEXmlParser xmlNodeWithData:[xmlStr2 dataUsingEncoding:NSUTF8StringEncoding] error:&error])
                .to(equal(expectedObj2));
            expect(error).to(beNil());
        });

        it(@"can parse escaped characters", ^{
            NSString* str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                            @"<response status=\"&amp;&quot;&lt;&gt;&apos;\">&amp;&quot;&lt;&gt;&apos;</response>";
            MXEXmlNode* expectedObj = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                                   attributes:@{ @"status" : @"&\"<>'" }
                                                                        value:@"&\"<>'"];

            __block MXEXmlNode* node;
            __block NSError* error = nil;
            expect(node = [MXEXmlParser xmlNodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding] error:&error])
                .to(equal(expectedObj));
            expect(error).to(beNil());
        });

        it(@"can parse correctly, even if parser:foundCharacters: is called more than once", ^{
            NSString* str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                            @"<response status=\"OK\">  Hello, \"World\"!!  </response>";

            MXEXmlNode* expectedObj = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                                   attributes:@{ @"status" : @"OK" }
                                                                        value:@"  Hello, \"World\"!!  "];

            __block MXEXmlNode* node;
            __block NSError* error = nil;
            expect(node = [MXEXmlParser xmlNodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding] error:&error])
                .to(equal(expectedObj));
            expect(error).to(beNil());
        });

        it(@"LF and space at edge are not deleted", ^{
            NSString* str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                            @"<response status=\"OK\">\n"
                            @"    aaa bbb ccc \n"
                            @"    ddd eee fff \n"
                            @"</response>";

            MXEXmlNode* expectedObj = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                                   attributes:@{ @"status" : @"OK" }
                                                                        value:@"\n    aaa bbb ccc \n    ddd eee fff \n"];

            __block MXEXmlNode* node;
            __block NSError* error = nil;
            expect(node = [MXEXmlParser xmlNodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding] error:&error])
                .to(equal(expectedObj));
            expect(error).to(beNil());
        });

        it(@"CR and CRLF are converted to one LF", ^{
            NSString* str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                            @"<response>\n"
                            @"a\r"
                            @"b\r\n"
                            @"</response>";

            MXEXmlNode* expectedObj = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                                   attributes:@{}
                                                                        value:@"\na\nb\n"];

            __block MXEXmlNode* node;
            __block NSError* error = nil;
            expect(node = [MXEXmlParser xmlNodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding] error:&error])
                .to(equal(expectedObj));
            expect(error).to(beNil());
        });

        it(@"Ideographic-spaces at edge are not deleted", ^{
            NSString* str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                            @"<response status=\"OK\">　　Hello, \"World\"!!　　</response>";

            MXEXmlNode* expectedObj = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                                   attributes:@{ @"status" : @"OK" }
                                                                        value:@"　　Hello, \"World\"!!　　"];

            __block MXEXmlNode* node;
            __block NSError* error = nil;
            expect(node = [MXEXmlParser xmlNodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding] error:&error])
                .to(equal(expectedObj));
            expect(error).to(beNil());
        });

        it(@"can parse CDATA. The value is combinatio of CDATA and text nodes", ^{
            NSString* str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                            @"<response status=\"OK\">\n"
                            @"    <![CDATA[    <aaa bbb ccc \n"
                            @"    ddd eee fff>  \n"
                            @"    ]]>\n"
                            @"</response>";

            MXEXmlNode* expectedObj = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                                   attributes:@{ @"status" : @"OK" }
                                                                        value:@"\n        <aaa bbb ccc \n    ddd eee fff>  \n    \n"];

            __block MXEXmlNode* node;
            __block NSError* error = nil;
            expect(node = [MXEXmlParser xmlNodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding] error:&error])
                .to(equal(expectedObj));
            expect(error).to(beNil());
        });

        it(@"returns error, when input data is invalid", ^{
            NSString* str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                            @"<root><child";

            __block MXEXmlNode* node;
            __block NSError* error = nil;
            expect(node = [MXEXmlParser xmlNodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding] error:&error])
                .to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(NSXMLParserErrorDomain));
        });
    });

    describe(@"dataWithXmlNode:declaration:error:", ^{
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                        attributes:@{ @"status" : @"OK" }
                                                             value:@"Hello, \"World\"!!"];

        it(@"returns nil, if xml declaration is invalid", ^{
            __block NSError* error = nil;
            expect([MXEXmlParser dataWithXmlNode:node declaration:@"<?xml version" error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidXmlDeclaration));
        });

        it(@"can returns NSData", ^{
            NSString* expectedStr = @"<?xml version=\"1.0\" encoding=\"shift_jis\"?>"
                                    @"<response status=\"OK\">Hello, &quot;World&quot;!!</response>";

            __block NSData* data = nil;
            __block NSError* error = nil;
            expect(data = [MXEXmlParser dataWithXmlNode:node
                                            declaration:@"<?xml version=\"1.0\" encoding=\"shift_jis\"?>"
                                                  error:&error])
                .notTo(beNil());
            expect([[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding]).to(equal(expectedStr));
            expect(error).to(beNil());
        });

        it(@"use default declaration, if it does not specify declaration", ^{
            NSString* expectedStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                    @"<response status=\"OK\">Hello, &quot;World&quot;!!</response>";

            __block NSData* data = nil;
            __block NSError* error = nil;
            expect(data = [MXEXmlParser dataWithXmlNode:node error:&error]).notTo(beNil());
            expect([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]).to(equal(expectedStr));
            expect(error).to(beNil());
        });
    });

#pragma mark - Private Method Tests

    describe(@"+xmlDeclarationToEncoding:", ^{
        it(@"utf8", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
            expect([MXEXmlParser xmlDeclarationToEncoding:xmlDeclaration error:nil]).to(equal(NSUTF8StringEncoding));
        });

        it(@"utf16", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"UTF-16\"?>";
            expect([MXEXmlParser xmlDeclarationToEncoding:xmlDeclaration error:nil]).to(equal(NSUTF16StringEncoding));
        });

        it(@"shift jis", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"Shift_JIS\"?>";
            expect([MXEXmlParser xmlDeclarationToEncoding:xmlDeclaration error:nil]).to(equal(NSShiftJISStringEncoding));
        });

        it(@"euc-jp", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"EUC-JP\"?>";
            expect([MXEXmlParser xmlDeclarationToEncoding:xmlDeclaration error:nil]).to(equal(NSJapaneseEUCStringEncoding));
        });

        it(@"lower case", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"euc-jp\"?>";
            expect([MXEXmlParser xmlDeclarationToEncoding:xmlDeclaration error:nil]).to(equal(NSJapaneseEUCStringEncoding));
        });

        it(@"returns default encoding, if encoding is not exist", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\"?>";
            expect([MXEXmlParser xmlDeclarationToEncoding:xmlDeclaration error:nil]).to(equal(NSUTF8StringEncoding));
        });

        it(@"invalid input data", ^{
            NSString* xmlDeclaration = @"<?XML ?>";
            __block NSError* error;
            expect([MXEXmlParser xmlDeclarationToEncoding:xmlDeclaration error:&error]).to(equal(0));
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidXmlDeclaration));
        });

        it(@"valid input data, but it does not support the encoding", ^{
            NSString* xmlDeclaration = @"<?xml version=\"1.0\" encoding=\"aaaa\"?>";
            __block NSError* error;
            expect([MXEXmlParser xmlDeclarationToEncoding:xmlDeclaration error:&error]).to(equal(0));
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorNotSupportedEncoding));
        });
    });
}
QuickSpecEnd
