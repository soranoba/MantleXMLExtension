//
//  MXEXmlAttributePath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlAttributePath+Private.h"
#import "MXEXmlNode.h"

@implementation MXEXmlAttributePath

- (instancetype _Nonnull)initWithNodePath:(id _Nonnull)nodePath
                             attributeKey:(NSString* _Nonnull)attributeKey
{
    NSParameterAssert(attributeKey != nil && attributeKey.length > 0);

    if (self = [super initWithNodePath:nodePath]) {
        self.attributeKey = attributeKey;
    }
    return self;
}

+ (instancetype _Nonnull)pathWithNodePath:(id _Nonnull)nodePath
                             attributeKey:(NSString* _Nonnull)attributeKey
{
    return [[self alloc] initWithNodePath:nodePath attributeKey:attributeKey];
}

#pragma mark - MXEXmlpath (override)

- (id _Nullable (^_Nonnull)(MXEXmlNode* _Nonnull))getValueBlocks
{
    return ^id _Nullable(MXEXmlNode* _Nonnull node)
    {
        NSParameterAssert(node != nil);
        return node.attributes[self.attributeKey];
    };
}

- (BOOL (^_Nonnull)(MXEXmlNode* _Nonnull node, id _Nullable value))setValueBlocks
{
    return ^BOOL(MXEXmlNode* _Nonnull node, id _Nullable value) {
        NSParameterAssert(node != nil);

        if (!value || [value isKindOfClass:NSString.class]) {
            if (![node.attributes isKindOfClass:NSMutableDictionary.class]) {
                node.attributes = [node.attributes mutableCopy];
            }

            if (value) {
                ((NSMutableDictionary*)node.attributes)[self.attributeKey] = value;
            } else {
                [((NSMutableDictionary*)node.attributes) removeObjectForKey:self.attributeKey];
            }
            return YES;
        }
        return NO;
    };
}

#pragma mark - NSCopying

- (instancetype _Nonnull)copyWithZone:(NSZone* _Nullable)zone
{
    MXEXmlAttributePath* result = [super copyWithZone:zone];

    if (result) {
        result.attributeKey = [self.attributeKey copyWithZone:zone];
    }
    return result;
}

@end
