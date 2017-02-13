//
//  MXEXmlNodePath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/12.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNodePath.h"

@interface MXEXmlNodePath ()
@property (nonatomic, nonnull, copy) NSArray<NSString*>* separatedPath;
@end

@implementation MXEXmlNodePath

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithPathString:(NSString* _Nonnull)pathString
{
    NSParameterAssert([pathString isKindOfClass:NSString.class]);

    if (self = [super init]) {
        self.separatedPath = [self.class separatePathString:pathString];
    }
    return self;
}

+ (instancetype _Nonnull)pathWithPathString:(NSString* _Nonnull)pathString
{
    return [[self alloc] initWithPathString:pathString];
}

#pragma mark - Public Methods

+ (NSArray<NSString*>* _Nonnull)separatePathString:(NSString* _Nullable)pathString
{
    NSArray<NSString*>* separatedPath = [pathString componentsSeparatedByString:@"."];
    NSMutableArray<NSString*>* filteredPath = [NSMutableArray array];

    // NOTE: Remove empty string
    for (NSString* pathFragment in separatedPath) {
        if (pathFragment.length) {
            [filteredPath addObject:pathFragment];
        }
    }
    return filteredPath;
}

#pragma mark - MXEXmlAccessible

- (MXEXmlNode* _Nullable)getValueFromXmlNode:(MXEXmlNode* _Nonnull)rootXmlNode
{
    NSParameterAssert(rootXmlNode != nil);

    MXEXmlNode* iterator = rootXmlNode;
    for (NSString* path in self.separatedPath) {
        iterator = [iterator lookupChild:path];
        if (!iterator) {
            return nil;
        }
    }
    return iterator;
}

- (void)setValue:(MXEXmlNode* _Nullable)xmlNodeToSet forXmlNode:(MXEMutableXmlNode* _Nonnull)rootXmlNode
{
    NSParameterAssert(rootXmlNode != nil);
    NSParameterAssert(xmlNodeToSet == nil || [xmlNodeToSet isKindOfClass:MXEXmlNode.class]);

    if (!self.separatedPath.count) {
        NSAssert(xmlNodeToSet != nil, @"It can NOT set nil to root node");
        [rootXmlNode setToCopyAllElementsFromXmlNode:xmlNodeToSet];
        return;
    }

    NSArray<NSString*>* separatedParentPath = [self.separatedPath subarrayWithRange:NSMakeRange(0, self.separatedPath.count - 1)];
    MXEMutableXmlNode* iterator = rootXmlNode;

    for (NSString* path in separatedParentPath) {
        MXEMutableXmlNode* nextIterator = (MXEMutableXmlNode*)[iterator lookupChild:path];
        if (!nextIterator) {
            nextIterator = [[MXEMutableXmlNode alloc] initWithElementName:path];
            [iterator addChild:nextIterator];
        }
        iterator = nextIterator;
    }

    NSString* elementNameToSet = [self.separatedPath lastObject];

    // NOTE: Rewrite the elementName to match the path
    MXEMutableXmlNode* mutableXmlNodeToSet;
    if ([xmlNodeToSet isKindOfClass:MXEMutableXmlNode.class]) {
        mutableXmlNodeToSet = (MXEMutableXmlNode*)xmlNodeToSet;
    } else {
        mutableXmlNodeToSet = [xmlNodeToSet mutableCopy];
    }
    mutableXmlNodeToSet.elementName = elementNameToSet;

    NSUInteger index = 0;
    for (; index < iterator.children.count; index++) {
        MXEMutableXmlNode* child = iterator.children[index];

        if ([child.elementName isEqualToString:elementNameToSet]) {
            if (mutableXmlNodeToSet) {
                [child setToCopyAllElementsFromXmlNode:mutableXmlNodeToSet];
            } else {
                [iterator.children removeObjectAtIndex:index];
            }
            return;
        }
    }
    [iterator addChild:mutableXmlNodeToSet];
}

#pragma mark - NSObject (Override)

- (NSString* _Nonnull)description
{
    return [NSString stringWithFormat:@"@\"%@\"", [self.separatedPath componentsJoinedByString:@"."]];
}

@end
