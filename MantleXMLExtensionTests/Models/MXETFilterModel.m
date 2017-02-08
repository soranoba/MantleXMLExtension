//
//  MXETFilterModel.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/08.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETFilterModel.h"

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

@implementation MXETFilterModel

#pragma mark - MXEXmlSerializing

+ (NSDictionary<NSString*, id>* _Nonnull)xmlKeyPathsByPropertyKey
{
    return @{ @"node" : @[ MXEXmlAttribute(@"", @"attribute"),
                           @"data.user" ] };
}

+ (NSString* _Nonnull)xmlRootElementName
{
    return @"root";
}

@end
