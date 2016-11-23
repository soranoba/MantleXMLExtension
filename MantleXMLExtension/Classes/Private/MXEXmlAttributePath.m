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

- (instancetype _Nonnull) initWithNodePath: (id _Nonnull)nodePath
                              attributeKey: (NSString* _Nonnull)attributeKey
{
    NSParameterAssert(attributeKey != nil && attributeKey.length > 0);

    if (self = [super initWithNodePath:nodePath]) {
        self.attributeKey = attributeKey;
    }
    return self;
}

+ (instancetype _Nonnull) pathWithNodePath: (id _Nonnull)nodePath
                              attributeKey: (NSString* _Nonnull)attributeKey
{
    return [[self alloc] initWithNodePath:nodePath attributeKey:attributeKey];
}

#pragma mark - MXEXmlpath (override)

- (id _Nullable(^ _Nonnull)(MXEXmlNode* _Nonnull)) getValueBlocks
{
    return ^(MXEXmlNode* node) {
        return node.attributes[self.attributeKey];
    };
}

- (BOOL (^ _Nonnull)(MXEXmlNode* _Nonnull node, id _Nonnull value)) setValueBlocks
{
    return ^(MXEXmlNode* node, id value) {
        if ([value isKindOfClass:NSString.class]) {
            if (![node.attributes isKindOfClass:NSMutableDictionary.class]) {
                node.attributes = [node.attributes mutableCopy];
            }
            ((NSMutableDictionary*)node.attributes)[self.attributeKey] = value;
            return YES;
        }
        return NO;
    };
}

@end
