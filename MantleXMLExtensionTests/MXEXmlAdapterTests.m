//
//  MXEXmlAdapterTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETSampleModel.h"

QuickSpecBegin(MXEXmlAdapterTests)

describe(@"Initializer validation", ^{
    __block id mock = nil;

    beforeEach(^{
        mock = OCMClassMock(MXETSampleModel.class);
    });

    afterEach(^{
        [mock stopMocking];
    });

    it(@"xmlKeyPathsByPropertyKey included properties isn't found in model", ^{
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"notFound":@"a"});
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());
    });
    it(@"xmlKeyPathsByPropertyKey included empty key fragments", ^{
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":@[]});
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());
    });
    it(@"xmlKeyPathsByPropertyKey included invalid key fragments", ^{
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":[NSObject new]});
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());

        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn((@{@"a":@[@"hoge", [NSObject new]]}));
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());

        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":[NSObject new]});
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).to(raiseException());
    });
    it(@"xmlKeyPathsByPropertyKey is valid", ^{
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn((@{@"a":@[@"hoge", @"fuga"]}));
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":@"a"});
        expect([[MXEXmlAdapter alloc] initWithModelClass:MXETSampleModel.class]).notTo(equal(nil));

        MXEXmlAttributePath* attribute;
        attribute = [[MXEXmlAttributePath alloc] initWithPaths:@[@"hoge", @"fuga"]];
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":attribute});

        attribute = [[MXEXmlAttributePath alloc] initWithRootAttribute:@"hoge"];
        OCMStub([mock xmlKeyPathsByPropertyKey]).andReturn(@{@"a":attribute});
    });
});

QuickSpecEnd
