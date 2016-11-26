//
//  MXEXmlPath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/23.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"
#import "MXEXmlPath+Private.h"

@implementation MXEXmlPath

- (instancetype _Nonnull)initWithNodePath:(id _Nonnull)nodePath
{
    NSParameterAssert([nodePath isKindOfClass:NSString.class] || [nodePath isKindOfClass:NSArray.class]);

    if (self = [super init]) {
        if ([nodePath isKindOfClass:NSString.class]) {
            self.separatedPath = [self.class separateNodePath:nodePath];
        } else {
            NSArray* paths = nodePath;
            NSMutableArray* separatedPath = [NSMutableArray array];

            for (id path in paths) {
                NSAssert([path isKindOfClass:NSString.class],
                         @"NodePath MUST NSString or array of NSString, but included %@", [path class]);
                [separatedPath addObjectsFromArray:[self.class separateNodePath:path]];
            }
            self.separatedPath = separatedPath;
        }
    }
    return self;
}

+ (instancetype _Nonnull)pathWithNodePath:(id _Nonnull)nodePath
{
    return [[self alloc] initWithNodePath:nodePath];
}

+ (NSArray<NSString*>* _Nonnull)separateNodePath:(NSString* _Nullable)nodePath
{
    NSArray<NSString*>* separatedPath = [nodePath componentsSeparatedByString:@"."];
    NSMutableArray<NSString*>* filteredPath = [NSMutableArray array];

    for (NSString* path in separatedPath) {
        if (path.length) {
            [filteredPath addObject:path];
        }
    }
    return filteredPath;
}

- (id _Nullable (^_Nonnull)(MXEXmlNode* _Nonnull))getValueBlocks
{
    return ^id(MXEXmlNode* _Nonnull node) {
        NSParameterAssert(node != nil);
        
        if ([node.children isKindOfClass:NSString.class]) {
            return node.children;
        }
        return (id)nil;
    };
}

- (BOOL (^_Nonnull)(MXEXmlNode* _Nonnull node, id _Nullable value))setValueBlocks
{
    return ^BOOL(MXEXmlNode* _Nonnull node, id _Nullable value) {
        NSParameterAssert(node != nil);

        if (!value || [value isKindOfClass:NSString.class]) {
            node.children = value;
            return YES;
        }
        return NO;
    };
}

#pragma mark - NSCopying

- (instancetype _Nonnull)copyWithZone:(NSZone* _Nullable)zone
{
    MXEXmlPath* result = [[[self class] allocWithZone:zone] init];

    if (result) {
        result.separatedPath = [[NSArray allocWithZone:zone] initWithArray:self.separatedPath copyItems:YES];
    }
    return result;
}

@end
