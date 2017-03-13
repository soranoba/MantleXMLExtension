//
//  MXETTypeModel.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/12/05.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETTypeModel.h"

@implementation MXETTypeModel

#pragma mark - MXEXmlSerializing

+ (NSDictionary<NSString*, id>* _Nonnull)xmlKeyPathsByPropertyKey
{
    return @{ @"intNum" : MXEXmlAttribute(@"", @"int"),
              @"uintNum" : MXEXmlAttribute(@"", @"uint"),
              @"doubleNum" : MXEXmlAttribute(@"", @"double"),
              @"floatNum" : MXEXmlAttribute(@"", @"float"),
              @"boolNum" : MXEXmlAttribute(@"", @"bool") };
}

+ (NSString* _Nonnull)xmlRootElementName
{
    return @"response";
}

@end
