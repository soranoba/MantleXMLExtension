//
//  MXEXmlAttributePath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlAttributePath+Private.h"

@implementation MXEXmlAttributePath

- (instancetype _Nullable) initWithNodePath: (NSString* _Nullable)nodePath
                               attributeKey: (NSString* _Nonnull)attributeKey
{
    NSParameterAssert(attributeKey != nil && attributeKey.length > 0);

    if (self = [super init]) {
        self.nodePath = nodePath;
        self.attributeKey = attributeKey;
    }
    return self;
}

+ (instancetype _Nullable) pathWithNode: (NSString* _Nullable)nodePath
                           attributeKey: (NSString* _Nonnull)attributeKey
{
    return [[self alloc] initWithNodePath:nodePath attributeKey:attributeKey];
}


@end
