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
                         @"children MUST be NSString or array of MXEXmlNode, but got %@", [child class]);

                MXEMutableXmlNode* dummyNode = [[MXEMutableXmlNode alloc] initWithElementName:@""];
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

- (BOOL (^_Nonnull)(MXEMutableXmlNode* _Nonnull node, id _Nullable value))setValueBlocks
{
    return ^BOOL(MXEMutableXmlNode* _Nonnull node, id _Nullable value) {
        NSParameterAssert(node != nil);

        if (!value) {
            value = @[];
        }
        if (![value isKindOfClass:NSArray.class]) {
            return NO;
        }

        NSString* childNodeName = [self.collectRelativePath.separatedPath firstObject];
        childNodeName = childNodeName ?: @"";

        MXEXmlPath* collectRelativePath = [self.collectRelativePath copy];
        if (collectRelativePath.separatedPath.count > 0) {
            NSRange range = NSMakeRange(1, collectRelativePath.separatedPath.count - 1);
            collectRelativePath.separatedPath = [collectRelativePath.separatedPath subarrayWithRange:range];
        }

        NSMutableArray* children;
        if ([node.children isKindOfClass:NSArray.class]) {
            children = [node.children mutableCopy];
        } else {
            children = [NSMutableArray arrayWithCapacity:((NSArray*)value).count];
        }

        int i = 0;
        for (id child in children) {
            NSAssert([child isKindOfClass:MXEXmlNode.class], @"");
            if ([((MXEXmlNode*)child).elementName isEqualToString:childNodeName]) {
                if (i >= [value count]) {
                    if (![(MXEMutableXmlNode*)child setValue:nil forXmlPath:collectRelativePath]) {
                        return NO;
                    }
                } else {
                    if (![(MXEMutableXmlNode*)child setValue:value[i] forXmlPath:collectRelativePath]) {
                        return NO;
                    }
                    i++;
                }
            }
        }
        for (; i < [value count]; i++) {
            MXEXmlNode* insertChild;
            if (childNodeName.length == 0 && [value[i] isKindOfClass:MXEXmlNode.class]) {
                insertChild = value[i];
            } else {
                insertChild = [[MXEXmlNode alloc] initWithXmlPath:self.collectRelativePath value:value[i]];
            }

            if (!insertChild) {
                return NO;
            }
            [(NSMutableArray*)children addObject:insertChild];
        }

        node.children = children;
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

#pragma mark - NSObject (Override)

- (NSString* _Nonnull)description
{
    return [NSString stringWithFormat:@"MXEXmlArray(@\"%@\", %@)",
                                      [self.separatedPath componentsJoinedByString:@"."], self.collectRelativePath];
}

@end
