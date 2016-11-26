//
//  MXEXmlChildNodePath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/23.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlChildNodePath+Private.h"
#import "MXEXmlNode.h"

@implementation MXEXmlChildNodePath

- (instancetype _Nonnull)initWithNodePath:(id _Nonnull)nodePath
{
    NSParameterAssert([nodePath isKindOfClass:NSString.class] || [nodePath isKindOfClass:NSArray.class]);

    NSArray* separatedNodePath;
    if ([nodePath isKindOfClass:NSString.class]) {
        separatedNodePath = [super.class separateNodePath:nodePath];
    } else {
        separatedNodePath = nodePath;
    }

    NSString* nodeName = [separatedNodePath lastObject];
    NSAssert(nodeName.length > 0, @"NodePath MUST contain at least one non-dot character");
    NSArray* parentPath = [separatedNodePath subarrayWithRange:NSMakeRange(0, separatedNodePath.count - 1)];

    if (self = [super initWithNodePath:parentPath]) {
        self.nodeName = nodeName;
    }
    return self;
}

+ (instancetype _Nonnull)pathWithNodePath:(id _Nonnull)nodePath
{
    return [[self alloc] initWithNodePath:nodePath];
}

#pragma mark - MXEXmlpath (override)

- (id _Nullable (^_Nonnull)(MXEXmlNode* _Nonnull))getValueBlocks
{
    return ^id _Nullable(MXEXmlNode* _Nonnull node)
    {
        NSParameterAssert(node != nil);
        return [node lookupChild:self.nodeName];
    };
}

- (BOOL (^_Nonnull)(MXEXmlNode* _Nonnull node, id _Nonnull value))setValueBlocks
{
    return ^BOOL(MXEXmlNode* _Nonnull node, id _Nonnull value) {
        NSParameterAssert(node != nil && value != nil);

        if (!([value isKindOfClass:MXEXmlNode.class]
              && ([node.children isKindOfClass:NSArray.class] || node.children == nil))) {
            return NO;
        }
        MXEXmlNode* insertNode = value;
        insertNode.elementName = self.nodeName;

        MXEXmlNode* foundNode = [node lookupChild:self.nodeName];
        if ([node.children isKindOfClass:NSArray.class]) {
            if (![node.children isKindOfClass:NSMutableArray.class]) {
                node.children = [node.children mutableCopy];
            }
        } else {
            node.children = [NSMutableArray array];
        }

        if (foundNode) {
            NSUInteger index = [node.children indexOfObject:foundNode];
            ((NSMutableArray*)node.children)[index] = insertNode;
        } else {
            [(NSMutableArray*)node.children addObject:insertNode];
        }
        return YES;
    };
}

#pragma mark - NSCopying

- (instancetype _Nonnull)copyWithZone:(NSZone* _Nullable)zone
{
    MXEXmlChildNodePath* result = [super copyWithZone:zone];

    if (result) {
        result.nodeName = [self.nodeName copyWithZone:zone];
    }
    return result;
}

@end
