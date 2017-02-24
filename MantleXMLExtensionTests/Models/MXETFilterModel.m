//
//  MXETFilterModel.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/08.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETFilterModel.h"

@implementation MXETFilterModel

#pragma mark - MXEXmlSerializing

+ (NSDictionary<NSString*, id>* _Nonnull)xmlKeyPathsByPropertyKey
{
    return @{ @"node" : [MXETFilterChildModel.class xmlKeyPathsByPropertyKey].allValues };
}

+ (NSString* _Nonnull)xmlRootElementName
{
    return @"root";
}

@end

@implementation MXETFilterChildModel

#pragma mark - MXEXmlSerializing

+ (NSDictionary<NSString*, id>* _Nonnull)xmlKeyPathsByPropertyKey
{
    return @{ @"userName" : @"data.user",
              @"attribute" : MXEXmlAttribute(@"", @"attribute") };
}

+ (NSString* _Nonnull)xmlRootElementName
{
    return @"root";
}

@end
