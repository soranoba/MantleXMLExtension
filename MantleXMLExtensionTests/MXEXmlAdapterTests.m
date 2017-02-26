//
//  MXEXmlAdapterTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETFilterModel.h"
#import "MXETSampleModel.h"
#import "MXETTypeModel.h"
#import "MXETUsersResponse.h"
#import "MXEXmlNode.h"
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@interface MXEXmlAdapter ()
+ (NSDictionary<NSString*, NSValueTransformer*>* _Nonnull)valueTransformersForModelClass:(Class _Nonnull)modelClass;
@end

@interface MXETUsersResponse ()
+ (NSValueTransformer* _Nonnull)usersXmlTransformer;
@end

QuickSpecBegin(MXEXmlAdapterTests)
{
    describe(@"Initializer validation", ^{
        __block id mock = nil;

        beforeEach(^{
            mock = OCMClassMock(MXETSampleModel.class);
        });

        afterEach(^{
            [mock stopMocking];
        });

        it(@"xmlKeyPathsByPropertyKey included properties isn't found in model", ^{
            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{ @"notFound" : @"a" });
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());
        });
        it(@"xmlKeyPathsByPropertyKey is array of NSNumber", ^{
            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{ @"a" : @[ @1 ] });
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());
        });
        it(@"xmlKeyPathsByPropertyKey is valid", ^{
            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{ @"a" : @"hoge.fuga" });
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{ @"a" : @"a" });
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{ @"a" : MXEXmlAttribute(@"hoge", @"fuga") });
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{ @"a" : MXEXmlArray(@"hoge", @"fuga") });
            expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

            OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn((@{ @"a" : @[ MXEXmlArray(@"hoge", @"fugo"), @"hoge.fugo" ] }));
        });
    });

    describe(@"valueTransformersForModelClass:", ^{
        __block id mock;

        afterEach(^{
            [mock stopMocking];
        });

        it(@"use the result, if xmlTransformerForKey: is defined", ^{
            mock = OCMClassMock(MXETUsersResponse.class);

            OCMStub([mock xmlTransformerForKey:
                              [OCMArg checkWithBlock:^BOOL(NSString* _Nonnull key) {
                                  return [key isEqualToString:@"userCount"];
                              }]])
                .andReturn([NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"1" : @"!!mock!!" }]);

            NSDictionary* transformers = [MXEXmlAdapter valueTransformersForModelClass:MXETUsersResponse.class];
            expect([transformers[@"userCount"] transformedValue:@"1"]).to(equal(@"!!mock!!"));
        });

        it(@"use the transformer, if <key>XmlTransformer is defined", ^{
            mock = OCMClassMock(MXETUsersResponse.class);

            OCMStub([mock usersXmlTransformer])
                .andReturn([NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"2" : @"!!mock!!" }]);

            NSDictionary* transformers = [MXEXmlAdapter valueTransformersForModelClass:MXETUsersResponse.class];
            expect([transformers[@"users"] transformedValue:@"2"]).to(equal(@"!!mock!!"));
        });

        it(@"choose <key>XmlTransformer in preference to xmlTransformerForKey:", ^{
            mock = OCMClassMock(MXETUsersResponse.class);

            OCMStub([mock usersXmlTransformer])
                .andReturn([NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"3" : @"usersXmlTransformer" }]);

            OCMStub([mock xmlTransformerForKey:
                              [OCMArg checkWithBlock:^BOOL(NSString* _Nonnull key) {
                                  return [key isEqualToString:@"users"];
                              }]])
                .andReturn([NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"3" : @"xmlTransformerForKey:" }]);

            NSDictionary* transformers = [MXEXmlAdapter valueTransformersForModelClass:MXETUsersResponse.class];
            expect([transformers[@"users"] transformedValue:@"3"]).to(equal(@"usersXmlTransformer"));
        });

        it(@"does not choose xmlTransformerForKey:, if <key>XmlTransformer returns nil", ^{
            mock = OCMClassMock(MXETUsersResponse.class);

            OCMStub([mock usersXmlTransformer]).andReturn(nil);

            OCMStub([mock xmlTransformerForKey:
                              [OCMArg checkWithBlock:^BOOL(NSString* _Nonnull key) {
                                  return [key isEqualToString:@"users"];
                              }]])
                .andReturn([NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"4" : @"xmlTransformerForKey:" }]);

            NSDictionary* transformers = [MXEXmlAdapter valueTransformersForModelClass:MXETUsersResponse.class];
            expect([transformers[@"users"] transformedValue:@"4"]).to(beNil());
        });

        it(@"choose defaultTransformer, if <key>XmlTransformer is not defined and xmlTransformerForKey: returns nil", ^{
            expect([MXETUsersResponse respondsToSelector:NSSelectorFromString(@"userCountXmlTransformer")]).to(equal(NO));
            expect([MXETUsersResponse respondsToSelector:@selector(xmlTransformerForKey:)]).to(equal(YES));
            expect([MXETUsersResponse xmlTransformerForKey:@"userCount"]).to(beNil());

            NSDictionary* transformers = [MXEXmlAdapter valueTransformersForModelClass:MXETUsersResponse.class];
            expect([transformers[@"userCount"] transformedValue:@"5"]).to(equal(@5));
        });
    });

    describe(@"serialize / deserialize", ^{
        it(@"supported basic type with default transformers", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response status=\"ok\">"
                               @"<summary>"
                               @"<count>2</count>"
                               @"</summary>"
                               @"<user first_name=\"Ai\" last_name=\"Asada\">"
                               @"<age>25</age>"
                               @"<sex>Woman</sex>"
                               @"</user>"
                               @"<user first_name=\"Ikuo\" last_name=\"Ikeda\">"
                               @"<age>32</age>"
                               @"<sex>Man</sex>"
                               @"<parent first_name=\"Umeo\" last_name=\"Ueda\">"
                               @"<age>50</age>"
                               @"<sex>Man</sex>"
                               @"</parent>"
                               @"<child first_name=\"Eiko\" last_name=\"Endo\">"
                               @"<age>10</age>"
                               @"<sex>Woman</sex>"
                               @"</child>"
                               @"</user>"
                               @"</response>";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError* error = nil;

            MXETUsersResponse* response = [MXEXmlAdapter modelOfClass:MXETUsersResponse.class
                                                          fromXmlData:xmlData
                                                                error:&error];
            expect(response.status).to(equal(@"ok"));
            expect(response.userCount).to(equal(2));
            expect(response.users.count).to(equal(2));

            expect(response.users[0].firstName).to(equal(@"Ai"));
            expect(response.users[0].lastName).to(equal(@"Asada"));
            expect(response.users[0].age).to(equal(25));
            expect(response.users[0].sex == MXETWoman).to(equal(YES));
            expect(response.users[0].parent).to(beNil());
            expect(response.users[0].child).to(beNil());

            expect(response.users[1].firstName).to(equal(@"Ikuo"));
            expect(response.users[1].lastName).to(equal(@"Ikeda"));
            expect(response.users[1].age).to(equal(32));
            expect(response.users[1].sex == MXETMan).to(equal(YES));
            expect(response.users[1].parent).notTo(beNil());
            expect(response.users[1].child).notTo(beNil());

            expect(response.users[1].parent.firstName).to(equal("Umeo"));
            expect(response.users[1].parent.lastName).to(equal("Ueda"));
            expect(response.users[1].parent.age).to(equal(50));
            expect(response.users[1].parent.sex == MXETMan).to(equal(YES));
            expect(response.users[1].parent.parent).to(beNil());
            expect(response.users[1].parent.child).to(beNil());

            expect(response.users[1].child.firstName).to(equal("Eiko"));
            expect(response.users[1].child.lastName).to(equal("Endo"));
            expect(response.users[1].child.age).to(equal(10));
            expect(response.users[1].child.sex == MXETWoman).to(equal(YES));
            expect(response.users[1].child.parent).to(beNil());
            expect(response.users[1].child.child).to(beNil());
            expect(error).to(beNil());

            NSData* gotXmlData = [MXEXmlAdapter xmlDataFromModel:response error:nil];
            expect(gotXmlData).to(equal(xmlData));
        });

        it(@"returns error, if input data is nil", ^{
            __block NSError* error = nil;

            void (^check)() = [^{
                expect(error).notTo(beNil());
                expect(error.domain).to(equal(MXEErrorDomain));
                expect(error.code).to(equal(MXEErrorNilInputData));
            } copy];

            error = nil;
            expect([MXEXmlAdapter modelOfClass:MXETSampleModel.class fromXmlData:nil error:&error]).to(beNil());
            check();

            error = nil;
            expect([MXEXmlAdapter modelOfClass:MXETSampleModel.class fromXmlNode:nil error:&error]).to(beNil());
            check();

            error = nil;
            expect([MXEXmlAdapter xmlDataFromModel:nil error:&error]).to(beNil());
            check();

            error = nil;
            expect([MXEXmlAdapter xmlNodeFromModel:nil error:&error]).to(beNil());
            check();

            MXEXmlAdapter* adapter = [[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class];

            error = nil;
            expect([adapter modelFromXmlData:nil error:&error]).to(beNil());
            check();

            error = nil;
            expect([adapter modelFromXmlNode:nil error:&error]).to(beNil());
            check();

            error = nil;
            expect([adapter xmlDataFromModel:nil error:&error]).to(beNil());
            check();

            error = nil;
            expect([adapter xmlNodeFromModel:nil error:&error]).to(beNil());
            check();
        });

        it(@"returns error, if element name of root node is not match specified one", ^{
            NSString* str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                            @"<root />";
            NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];

            id mock = OCMClassMock(MXETSampleModel.class);
            OCMStub([mock xmlRootElementName]).andReturn(@"root");

            __block NSError* error = nil;
            expect([MXEXmlAdapter modelOfClass:MXETSampleModel.class fromXmlData:data error:&error]).notTo(beNil());
            expect(error).to(beNil());

            [mock stopMocking];

            error = nil;
            expect([MXEXmlAdapter modelOfClass:MXETSampleModel.class fromXmlData:data error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorElementNameDoesNotMatch));
        });
    });

    describe(@"speciry array in xmlKeyPath", ^{
        NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                           @"<root attribute=\"aaa\">"
                           @"<data><user>Alice</user></data>"
                           @"</root>";
        NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

        it(@"can specify array in xmlKeyPath", ^{
            __block MXETFilterModel* model;
            __block NSError* error = nil;
            expect(model = [MXEXmlAdapter modelOfClass:MXETFilterModel.class fromXmlData:xmlData error:&error]).notTo(beNil());
            expect(model.node.attribute).to(equal(@"aaa"));
            expect(model.node.userName).to(equal(@"Alice"));
            expect(error).to(beNil());

            __block NSData* gotData;
            expect(gotData = [MXEXmlAdapter xmlDataFromModel:model error:&error]).notTo(beNil());
            expect([[NSString alloc] initWithData:gotData encoding:NSUTF8StringEncoding]).to(equal(xmlStr));
            expect(error).to(beNil());
        });

        it(@"does not need to be the same xmlRootElementName as parent", ^{
            id mock = OCMClassMock(MXETFilterChildModel.class);
            OCMStub([mock xmlRootElementName]).andReturn(@"otherElementName");

            __block MXETFilterModel* model;
            __block NSError* error = nil;
            expect(model = [MXEXmlAdapter modelOfClass:MXETFilterModel.class fromXmlData:xmlData error:&error]).notTo(beNil());
        });

        it(@"returns model that does not have node, if the specified elements does not exist", ^{
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<root />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            __block MXETFilterModel* model;
            __block NSError* error = nil;
            expect(model = [MXEXmlAdapter modelOfClass:MXETFilterModel.class fromXmlData:xmlData error:&error]).notTo(beNil());
            expect(model.node).to(beNil());
            expect(error).to(beNil());

            __block NSData* gotData;
            expect(gotData = [MXEXmlAdapter xmlDataFromModel:model error:&error]).notTo(beNil());
            expect([[NSString alloc] initWithData:gotData encoding:NSUTF8StringEncoding]).to(equal(xmlStr));
            expect(error).to(beNil());
        });
    });

    describe(@"xmlDeclaration", ^{
        it(@"can specify a xml declaration", ^{
            id mock = OCMClassMock(MXETSampleModel.class);
            OCMStub([mock xmlDeclaration]).andReturn(@"<?xml version=\"1.0\" encoding=\"shift_jis\"?>");

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"shift_jis\"?>"
                                       @"<response />";

            __block NSData* data;
            __block NSError* error = nil;
            expect(data = [MXEXmlAdapter xmlDataFromModel:[MXETSampleModel new] error:&error]).notTo(beNil());
            expect([[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding]).to(equal(expectedXmlStr));
        });

        it(@"use default declaration, if xmlDeclaration is not defined", ^{
            id mock = OCMClassMock(MXETSampleModel.class);
            OCMStub([mock respondsToSelector:@selector(xmlDeclaration)]).andReturn(OCMOCK_VALUE(NO));

            NSString* expectedXmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       @"<response />";

            __block NSData* data;
            __block NSError* error = nil;
            expect(data = [MXEXmlAdapter xmlDataFromModel:[MXETSampleModel new] error:&error]).notTo(beNil());
            expect([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]).to(equal(expectedXmlStr));
        });

        it(@"returns error, if xmlDeclaration is invalid", ^{
            id mock = OCMClassMock(MXETSampleModel.class);
            OCMStub([mock xmlDeclaration]).andReturn(@"<?xml version=\"1.0\"");

            __block NSData* data;
            __block NSError* error = nil;
            expect(data = [MXEXmlAdapter xmlDataFromModel:[MXETSampleModel new] error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorInvalidXmlDeclaration));
        });
    });

    describe(@"classForParsingXmlNode:", ^{
        it(@"returns the model specified by classForParsingXmlNode:", ^{
            id mock = OCMClassMock(MXETSampleModel.class);
            OCMStub([mock classForParsingXmlNode:OCMOCK_ANY]).andReturn(MXETUser.class);
            OCMStub([mock xmlRootElementName]).andReturn(@"user");

            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<user first_name=\"Asada\" last_name=\"Ai\">"
                               @"  <age>20</age>"
                               @"  <sex>Woman</sex>"
                               @"</user>";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            __block NSError* error = nil;
            __block id model;
            expect(model = [MXEXmlAdapter modelOfClass:MXETSampleModel.class fromXmlData:xmlData error:&error]).notTo(beNil());
            expect(error).to(beNil());
            expect([model isMemberOfClass:MXETUser.class]).to(equal(YES));

            MXETUser* user = model;
            expect(user.firstName).to(equal(@"Asada"));
            expect(user.lastName).to(equal(@"Ai"));
        });

        it(@"returns nil, if own xmlRootElementName is different from that of the specified class", ^{
            id mock = OCMClassMock(MXETSampleModel.class);
            OCMStub([mock classForParsingXmlNode:OCMOCK_ANY]).andReturn(MXETUser.class);
            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<user first_name=\"Asada\" last_name=\"Ai\">"
                               @"  <age>20</age>"
                               @"  <sex>Woman</sex>"
                               @"</user>";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            __block NSError* error = nil;
            expect([MXEXmlAdapter modelOfClass:MXETSampleModel.class fromXmlData:xmlData error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorElementNameDoesNotMatch));
        });

        it(@"can returns model, if classForParsingXmlNode: returns itself class", ^{
            id mock = OCMClassMock(MXETSampleModel.class);
            OCMStub([mock classForParsingXmlNode:OCMOCK_ANY]).andReturn(MXETSampleModel.class);

            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            __block NSError* error = nil;
            __block id model;
            expect(model = [MXEXmlAdapter modelOfClass:MXETSampleModel.class fromXmlData:xmlData error:&error]).notTo(beNil());
            expect(error).to(beNil());
            expect([model isMemberOfClass:MXETSampleModel.class]).to(equal(YES));
        });

        it(@"returns nil, if classForParsingXmlNode: returns nil", ^{
            __block id returnValue = nil;

            id mock = OCMClassMock(MXETSampleModel.class);
            OCMStub([mock classForParsingXmlNode:OCMOCK_ANY]).andDo(^(NSInvocation* invocation) {
                [invocation setReturnValue:&returnValue];
            });

            NSString* xmlStr = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               @"<response />";
            NSData* xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

            __block NSError* error = nil;
            expect([MXEXmlAdapter modelOfClass:MXETSampleModel.class fromXmlData:xmlData error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MXEErrorDomain));
            expect(error.code).to(equal(MXEErrorNoConversionTarget));
        });
    });
}
QuickSpecEnd
