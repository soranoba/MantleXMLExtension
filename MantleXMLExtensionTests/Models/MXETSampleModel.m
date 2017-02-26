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

+ (NSString* _Nonnull)xmlDeclaration
{
    return @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
}

#pragma mark - NSObject (Override)

- (BOOL)isEqual:(id _Nullable)object
{
    if (![object isKindOfClass:self.class]) {
        return NO;
    }

    typeof(self) other = object;
    return [self.a isEqual:other.a] && [self.b isEqual:other.b] && [self.c isEqual:other.c];
}

@end
