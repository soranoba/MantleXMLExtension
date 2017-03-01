//
//  MXEXmlAdapter+TransformeresTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/19.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETSampleModel.h"
#import "MXEXmlAdapter.h"
#import "MXEXmlNode.h"

QuickSpecBegin(MXEXmlAdapter_TransformersTests)
{
    describe(@"xmlNodeArrayTransformerWithModelClass:", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer
            = [MXEXmlAdapter xmlNodeArrayTransformerWithModelClass:MXETSampleModel.class];

        MXEXmlNode* node1 = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                         attributes:@{ @"a" : @"a1" }
                                                           children:@[ [[MXEXmlNode alloc] initWithElementName:@"b"
                                                                                                    attributes:nil
                                                                                                         value:@"b1"],
                                                                       [[MXEXmlNode alloc] initWithElementName:@"c"
                                                                                                    attributes:nil
                                                                                                         value:@"c1"] ]];
        MXEXmlNode* node2 = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                         attributes:@{ @"a" : @"a2" }
                                                           children:@[ [[MXEXmlNode alloc] initWithElementName:@"b"
                                                                                                    attributes:nil
                                                                                                         value:@"b2"],
                                                                       [[MXEXmlNode alloc] initWithElementName:@"c"
                                                                                                    attributes:nil
                                                                                                         value:@"c2"] ]];

        MXETSampleModel* model1 = [MXETSampleModel new];
        model1.a = @"a1";
        model1.b = @"b1";
        model1.c = @"c1";
        MXETSampleModel* model2 = [MXETSampleModel new];
        model2.a = @"a2";
        model2.b = @"b2";
        model2.c = @"c2";

        __block id mock;

        beforeEach(^{
            mock = OCMClassMock(MXETSampleModel.class);
            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn((@{ @"a" : MXEXmlAttribute(@"", @"a"),
                                                                   @"b" : @"b",
                                                                   @"c" : @"c" }));
        });

        afterEach(^{
            [mock stopMocking];
        });

        it(@"can convert between array of model and array of MXEXmlNode", ^{
            expect([transformer transformedValue:@[ node1, node2 ]]).to(equal(@[ model1, model2 ]));
            expect([transformer reverseTransformedValue:@[ model1, model2 ]]).to(equal(@[ node1, node2 ]));
        });

        it(@"sets YES to success, when the conversion is successful", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@[ node1, node2 ] success:&success error:&error]).to(equal(@[ model1, model2 ]));
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:@[ model1, model2 ] success:&success error:&error]).to(equal(@[ node1, node2 ]));
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets YES to success, if input value is nil", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets NO to success, when input value is invalid type", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@[ @"1", @"2" ] success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MTLTransformerErrorHandlingErrorDomain));
            expect(error.code).to(equal(MTLTransformerErrorHandlingErrorInvalidInput));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@[ @"1", @"2" ] success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MTLTransformerErrorHandlingErrorDomain));
            expect(error.code).to(equal(MTLTransformerErrorHandlingErrorInvalidInput));

            success = NO;
            error = nil;
            expect([transformer transformedValue:@"1" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MTLTransformerErrorHandlingErrorDomain));
            expect(error.code).to(equal(MTLTransformerErrorHandlingErrorInvalidInput));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@"1" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MTLTransformerErrorHandlingErrorDomain));
            expect(error.code).to(equal(MTLTransformerErrorHandlingErrorInvalidInput));
        });
    });

    describe(@"xmlNodeTransformerWithModelClass:", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer
            = [MXEXmlAdapter xmlNodeTransformerWithModelClass:MXETSampleModel.class];

        MXEXmlNode* node1 = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                         attributes:@{ @"a" : @"a1" }
                                                           children:@[ [[MXEXmlNode alloc] initWithElementName:@"b"
                                                                                                    attributes:nil
                                                                                                         value:@"b1"],
                                                                       [[MXEXmlNode alloc] initWithElementName:@"c"
                                                                                                    attributes:nil
                                                                                                         value:@"c1"] ]];

        MXETSampleModel* model1 = [MXETSampleModel new];
        model1.a = @"a1";
        model1.b = @"b1";
        model1.c = @"c1";

        __block id mock;

        beforeEach(^{
            mock = OCMClassMock(MXETSampleModel.class);
            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn((@{ @"a" : MXEXmlAttribute(@"", @"a"),
                                                                   @"b" : @"b",
                                                                   @"c" : @"c" }));
        });

        afterEach(^{
            [mock stopMocking];
        });

        it(@"can convert between model and MXEXmlNode", ^{
            expect([transformer transformedValue:node1]).to(equal(model1));
            expect([transformer reverseTransformedValue:model1]).to(equal(node1));
        });

        it(@"can convert to model from MXEXmlNode, regardless of whether root element name matches", ^{
            OCMStub([mock xmlRootElementName]).andReturn(@"otherElementName");
            expect([transformer transformedValue:node1]).to(equal(model1));
        });

        it(@"sets YES to success, when the conversion is successful", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:node1 success:&success error:&error]).to(equal(model1));
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:model1 success:&success error:&error]).to(equal(node1));
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets YES to success, if input value is nil", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets NO to success, when input value is invalid type", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@"1" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidInputData));
            expect(error.userInfo[MXEErrorInputDataKey]).to(equal(@"1"));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@"1" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidInputData));
            expect(error.userInfo[MXEErrorInputDataKey]).to(equal(@"1"));
        });
    });

    describe(@"mappingDictionaryTransformerWithKeyPath:valuePath:", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer
            = [MXEXmlAdapter mappingDictionaryTransformerWithKeyPath:MXEXmlAttribute(@"b", @"id")
                                                           valuePath:@"b"];

        MXEXmlNode* aChild1 = [[MXEXmlNode alloc] initWithElementName:@"aChild"
                                                           attributes:nil
                                                                value:@"aChild_value"];
        MXEXmlNode* a1 = [[MXEXmlNode alloc] initWithElementName:@"a"
                                                      attributes:@{ @"id" : @"a_id" }
                                                        children:@[ aChild1 ]];
        MXEXmlNode* a2 = [[MXEXmlNode alloc] initWithElementName:@"a"
                                                      attributes:@{ @"id" : @"a_id" }
                                                        children:@[ aChild1 ]];
        MXEXmlNode* b1 = [[MXEXmlNode alloc] initWithElementName:@"b"
                                                      attributes:@{ @"id" : @"b_id1" }
                                                           value:@"b_value1"];
        MXEXmlNode* b2 = [[MXEXmlNode alloc] initWithElementName:@"b"
                                                      attributes:@{ @"id" : @"b_id2" }
                                                           value:@"b_value2"];
        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"response"
                                                        attributes:@{ @"id" : @"root" }
                                                          children:@[ a1, a2, b1, b2 ]];

        it(@"can convert between MXEXmlNode and NSDictionary", ^{
            expect([transformer transformedValue:node])
                .to(equal(@{ @"b_id1" : @"b_value1",
                             @"b_id2" : @"b_value2" }));

            MXEXmlNode* expectedNode = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                                    attributes:nil
                                                                      children:@[ b1, b2 ]];
            expect([transformer reverseTransformedValue:@{ @"b_id1" : @"b_value1",
                                                           @"b_id2" : @"b_value2" }])
                .to(equal(expectedNode));
        });

        it(@"ignore the backward, if there are multiple same key", ^{
            MXEMutableXmlNode* copyB1 = [b1 mutableCopy];
            copyB1.value = @"b_overwrite";
            MXEMutableXmlNode* copyNode = [node mutableCopy];
            copyNode.children = [@[ a1, a2, copyB1, b1, b2 ] mutableCopy];

            expect([transformer transformedValue:copyNode])
                .to(equal(@{ @"b_id1" : @"b_overwrite",
                             @"b_id2" : @"b_value2" }));
        });

        it(@"can refer to root", ^{
            NSValueTransformer<MTLTransformerErrorHandling>* transformer
                = [MXEXmlAdapter mappingDictionaryTransformerWithKeyPath:@"b"
                                                               valuePath:MXEXmlAttribute(@"", @"id")];

            expect([transformer transformedValue:node])
                .to(equal(@{ @"b_value1" : @"root",
                             @"b_value2" : @"root" }));

            // NOTE: Since key is found for any child, the value found first is NSNull.null
            transformer = [MXEXmlAdapter mappingDictionaryTransformerWithKeyPath:MXEXmlAttribute(@"", @"id")
                                                                       valuePath:@"b"];
            expect([transformer transformedValue:node]).to(equal(@{ @"root" : NSNull.null }));
        });

        it(@"sets YES to success, when the conversion is successful", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:node success:&success error:&error])
                .to(equal(@{ @"b_id1" : @"b_value1",
                             @"b_id2" : @"b_value2" }));
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            MXEXmlNode* expectedNode = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                                    attributes:nil
                                                                      children:@[ b1, b2 ]];
            expect([transformer reverseTransformedValue:@{ @"b_id1" : @"b_value1",
                                                           @"b_id2" : @"b_value2" }
                                                success:&success
                                                  error:&error])
                .to(equal(expectedNode));
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets YES to success, if input value is nil", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets NO to success, when input value is invalid type", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@"aa" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidInputData));
            expect(error.userInfo[MXEErrorInputDataKey]).to(equal(@"aa"));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@"aa" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidInputData));
            expect(error.userInfo[MXEErrorInputDataKey]).to(equal(@"aa"));
        });

        it(@"throw exception, if path is invalid", ^{
            __block NSValueTransformer<MTLTransformerErrorHandling>* transformer;
            expectAction(^{
                transformer = [MXEXmlAdapter mappingDictionaryTransformerWithKeyPath:@1
                                                                           valuePath:MXEXmlAttribute(@"", @"id")];
            }).to(raiseException());
            expectAction(^{
                transformer = [MXEXmlAdapter mappingDictionaryTransformerWithKeyPath:MXEXmlAttribute(@"", @"id")
                                                                           valuePath:@1];
            }).to(raiseException());
        });
    });

    describe(@"dictionaryTransformer", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer = [MXEXmlAdapter dictionaryTransformer];

        MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:@"root"
                                                        attributes:@{ @"a" : @"a_v",
                                                                      @"b" : @"b_v" }
                                                             value:@"value"];
        MXEMutableXmlNode* expectedNode = [node mutableCopy];
        expectedNode.elementName = @"dummy";

        it(@"can convert between MXEXmlNode and dictionary", ^{
            id mock = OCMPartialMock(node);
            OCMExpect([mock toDictionary]).andForwardToRealObject();
            expect([transformer transformedValue:node]).to(equal(@{ @"@a" : @"a_v",
                                                                    @"@b" : @"b_v",
                                                                    @"" : @"value" }));
            OCMVerify(mock);

            expect([transformer reverseTransformedValue:@{ @"@a" : @"a_v",
                                                           @"@b" : @"b_v",
                                                           @"" : @"value" }])
                .to(equal(expectedNode));
        });

        it(@"sets YES to success, when the conversion is successful", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:node success:&success error:&error])
                .to(equal(@{ @"@a" : @"a_v",
                             @"@b" : @"b_v",
                             @"" : @"value" }));
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:@{ @"@a" : @"a_v",
                                                           @"@b" : @"b_v",
                                                           @"" : @"value" }
                                                success:&success
                                                  error:&error])
                .to(equal(expectedNode));
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets YES to success, if input value is nil", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets NO to success, when input value is invalid type", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@"aa" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidInputData));
            expect(error.userInfo[MXEErrorInputDataKey]).to(equal(@"aa"));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@"aa" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidInputData));
            expect(error.userInfo[MXEErrorInputDataKey]).to(equal(@"aa"));
        });
    });

    describe(@"numberTransformer", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer = [MXEXmlAdapter numberTransformer];

        it(@"can convert between integer and string", ^{
            expect([transformer transformedValue:@"1389477961"]).to(equal(@1389477961));
            expect([transformer transformedValue:@"+1389477961"]).to(equal(@1389477961));
            expect([transformer transformedValue:@"-1389477961"]).to(equal(@(-1389477961)));

            expect([transformer reverseTransformedValue:@1389477961]).to(equal(@"1389477961"));
            expect([transformer reverseTransformedValue:@(-1389477961)]).to(equal(@"-1389477961"));
        });

        it(@"can convert between float and string", ^{
            expect([transformer transformedValue:@"20.25f"]).to(equal(@20.25));
            expect([transformer transformedValue:@"20.25"]).to(equal(@20.25));
            expect([transformer transformedValue:@"+20.25"]).to(equal(@20.25));
            expect([transformer transformedValue:@"+20.25f"]).to(equal(@20.25));
            expect([transformer transformedValue:@"-20.25"]).to(equal(@(-20.25)));
            expect([transformer transformedValue:@"-20.25f"]).to(equal(@(-20.25)));

            expect([transformer reverseTransformedValue:@20.25]).to(equal(@"20.25"));
            expect([transformer reverseTransformedValue:@(-20.25)]).to(equal(@"-20.25"));
        });

        it(@"can convert to double from string", ^{
            expect([transformer transformedValue:@"1.797693"]).to(equal(@1.797693));
            expect([transformer transformedValue:@"+1.797693"]).to(equal(@1.797693));
            expect([transformer transformedValue:@"-1.797693"]).to(equal(@(-1.797693)));

            expect([transformer reverseTransformedValue:@1.797693]).to(equal(@"1.797693"));
            expect([transformer reverseTransformedValue:@(-1.797693)]).to(equal(@"-1.797693"));
        });

        it(@"sets YES to success, when the conversion is successful", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@"1389477961" success:&success error:&error]).to(equal(@1389477961));
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:@1389477961 success:&success error:&error]).to(equal(@"1389477961"));
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets YES to success, if input value is nil", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets NO to success, when input value is invalid type", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@"aa" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidInputData));
            expect(error.userInfo[MXEErrorInputDataKey]).to(equal(@"aa"));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@"aa" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidInputData));
            expect(error.userInfo[MXEErrorInputDataKey]).to(equal(@"aa"));
        });
    });

    describe(@"boolTransformer", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer = [MXEXmlAdapter boolTransformer];

        it(@"can convert to bool from string of integer", ^{
            expect([transformer transformedValue:@"1"]).to(equal(YES));
            expect([transformer transformedValue:@"-1"]).to(equal(YES));
            expect([transformer transformedValue:@"0"]).to(equal(NO));
        });

        it(@"can convert to bool from string of boolean", ^{
            expect([transformer transformedValue:@"true"]).to(equal(YES));
            expect([transformer transformedValue:@"false"]).to(equal(NO));
        });

        it(@"can convert to bool from string", ^{
            expect([transformer transformedValue:@"t"]).to(equal(YES));
            expect([transformer transformedValue:@"y"]).to(equal(YES));
            expect([transformer transformedValue:@"f"]).to(equal(NO));
            expect([transformer transformedValue:@"n"]).to(equal(NO));
            expect([transformer transformedValue:@""]).to(equal(NO));
        });

        it(@"can convert to string of boolean from bool", ^{
            expect([transformer reverseTransformedValue:@YES]).to(equal(@"true"));
            expect([transformer reverseTransformedValue:@NO]).to(equal(@"false"));
        });

        it(@"can convert to string of boolean from integer", ^{
            expect([transformer reverseTransformedValue:@1]).to(equal(@"true"));
            expect([transformer reverseTransformedValue:@(-1)]).to(equal(@"true"));
            expect([transformer reverseTransformedValue:@0]).to(equal(@"false"));
        });

        it(@"sets YES to success, when the conversion is successful", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@"true" success:&success error:&error]).to(equal(YES));
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:@YES success:&success error:&error]).to(equal(@"true"));
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets YES to success, if input value is nil", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets NO to success, when input value is invalid type", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@1 success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidInputData));
            expect(error.userInfo[MXEErrorInputDataKey]).to(equal(@1));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@"1" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidInputData));
            expect(error.userInfo[MXEErrorInputDataKey]).to(equal(@"1"));
        });
    });
}
QuickSpecEnd
