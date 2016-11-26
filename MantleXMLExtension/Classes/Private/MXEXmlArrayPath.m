//
//  MXEXmlArrayPath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlArrayPath+Private.h"
#import "MXEXmlNode.h"

@implementation MXEXmlArrayPath

- (instancetype _Nonnull)initWithParentNodePath:(id _Nonnull)parentNodePath
                            collectRelativePath:(id _Nonnull)collectRelativePath
{
    NSParameterAssert(parentNodePath != nil && collectRelativePath != nil);

    if (self = [super initWithNodePath:parentNodePath]) {
        if ([collectRelativePath isKindOfClass:MXEXmlPath.class]) {
            self.collectRelativePath = collectRelativePath;
        } else {
            self.collectRelativePath = [MXEXmlPath pathWithNodePath:collectRelativePath];
        }
    }
    return self;
}

+ (instancetype _Nonnull)pathWithParentNodePath:(id _Nonnull)parentNodePath
                            collectRelativePath:(id _Nonnull)collectRelativePath
{
    return [[self alloc] initWithParentNodePath:parentNodePath
                            collectRelativePath:collectRelativePath];
}

#pragma mark - MXEXmlpath (override)

- (id _Nullable (^_Nonnull)(MXEXmlNode* _Nonnull))getValueBlocks
{
    return ^id _Nullable(MXEXmlNode* _Nonnull node)
    {
        NSParameterAssert(node != nil);

        if ([node.children isKindOfClass:NSArray.class]) {
            NSArray* children = node.children;
            NSMutableArray* result = [NSMutableArray array];

            for (id child in children) {
                NSAssert([child isKindOfClass:MXEXmlNode.class],
                         @"children MUST be NSString* or array of MXEXmlNode*, but got %@", [child class]);

                MXEXmlNode* dummyNode = [[MXEXmlNode alloc] initWithElementName:@""];
                dummyNode.children = @[ child ];
                id value = [dummyNode getForXmlPath:self.collectRelativePath];
                if (value) {
                    [result addObject:value];
                }
            }

            if (result.count > 0) {
                return result;
            }
        }
        return (NSMutableArray*)nil;
    };
}

- (BOOL (^_Nonnull)(MXEXmlNode* _Nonnull node, id _Nonnull value))setValueBlocks
{
    return ^BOOL(MXEXmlNode* _Nonnull node, id _Nonnull value) {
        NSParameterAssert(node != nil && value != nil);

        if (![value isKindOfClass:NSArray.class]) {
            return NO;
        }

        NSString* childNodeName = [self.collectRelativePath.separatedPath firstObject];
        childNodeName = childNodeName ?: @"";

        if (node.children == nil) {
            node.children = [NSMutableArray array];
        } else if ([node.children isKindOfClass:NSArray.class]) {
            NSMutableArray* children = [NSMutableArray array];
            for (id child in node.children) {
                if ([child isKindOfClass:MXEXmlNode.class]
                    && ![((MXEXmlNode*)child).elementName isEqualToString:childNodeName]) {

                    [children addObject:child];
                }
            }
            node.children = children;
        } else {
            return NO;
        }

        for (id v in (NSArray*)value) {
            MXEXmlNode* insertChild;
            if (childNodeName.length == 0 && [v isKindOfClass:MXEXmlNode.class]) {
                insertChild = v;
            } else {
                insertChild = [[MXEXmlNode alloc] initWithXmlPath:self.collectRelativePath value:v];
            }

            if (!insertChild) {
                return NO;
            }
            [(NSMutableArray*)node.children addObject:insertChild];
        }
        return YES;
    };
}

#pragma mark - NSCopying

- (instancetype _Nonnull)copyWithZone:(NSZone* _Nullable)zone
{
    MXEXmlArrayPath* result = [super copyWithZone:zone];

    if (result) {
        result.collectRelativePath = [self.collectRelativePath copyWithZone:zone];
    }
    return result;
}

@end
