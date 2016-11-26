//
//  MXETUsersResponse.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETUsersResponse.h"
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation MXETUsersResponse

#pragma mark - MXEXmlSerializing

+ (NSDictionary<NSString*, id>* _Nonnull)xmlKeyPathsByPropertyKey
{
    return @{ @"status" : MXEXmlAttribute(@"", @"status"),
              @"userCount" : @"summary.count",
              @"users" : MXEXmlArray(@"", MXEXmlChildNode(@"user")) };
}

+ (NSString* _Nonnull)xmlRootElementName
{
    return @"response";
}

+ (NSArray* _Nonnull)xmlChildNodeOrder
{
    return @[ @"userCount", @"users" ];
}

#pragma mark xml transformer

+ (NSValueTransformer* _Nonnull)usersXmlTransformer
{
    return [MXEXmlAdapter xmlNodeArrayTransformerWithModelClass:MXETUser.class];
}

#pragma mark - MTLModel (Override)

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    // NOTE: All elements are nullable.
    return [super validate:error];
}

@end

@implementation MXETUser

#pragma mark - MXEXmlSerializing

+ (NSDictionary<NSString*, id>* _Nonnull)xmlKeyPathsByPropertyKey
{
    return @{ @"firstName" : MXEXmlAttribute(@"", @"first_name"),
              @"lastName" : MXEXmlAttribute(@"", @"last_name"),
              @"age" : @"age",
              @"sex" : @"sex",
              @"parent" : MXEXmlChildNode(@"parent"),
              @"child" : MXEXmlChildNode(@"child") };
}

+ (NSString* _Nonnull)xmlRootElementName
{
    return @"user";
}

+ (NSArray* _Nonnull)xmlChildNodeOrder
{
    return @[ @"age", @"sex", @"parent", @"child" ];
}

#pragma mark xml transformer

+ (NSValueTransformer* _Nonnull)sexXmlTransformer
{
    NSDictionary* map = @{ @"Man" : @(MXETMan),
                           @"Woman" : @(MXETWoman) };
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:map];
}

#pragma mark - MTLModel (Override)

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    // NOTE: parent and child are nullable.
    return self.firstName != nil && self.lastName != nil && self.age > 0 && self.sex != 0;
}

@end
