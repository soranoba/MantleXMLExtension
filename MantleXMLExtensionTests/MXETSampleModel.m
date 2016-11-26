//
//  MXETSampleModel.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETSampleModel.h"

@implementation MXETSampleModel

#pragma mark - MXEXmlSerialing

+ (NSDictionary<NSString*, id>* _Nonnull)xmlKeyPathsByPropertyKey
{
    return @{};
}

+ (NSString* _Nonnull)xmlRootElementName
{
    return @"response";
}

@end
