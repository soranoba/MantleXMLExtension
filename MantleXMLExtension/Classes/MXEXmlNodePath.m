//
//  MXEXmlNodePath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/12.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNodePath.h"

@implementation MXEXmlNodePath

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithNodePath:(id _Nonnull)nodePath
{
    NSParameterAssert([nodePath isKindOfClass:NSString.class]);

    if (self = [super init]) {
        self.separatedPath = [self.class separateNodePath:nodePath];
    }
    return self;
}

+ (instancetype _Nonnull)pathWithNodePath:(id _Nonnull)nodePath
{
    return [[self alloc] initWithNodePath:nodePath];
}

#pragma mark - Public Methods

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

#pragma mark - MXEXmlAccessible

- (MXEXmlNode* _Nullable)getValueFromXmlNode:(MXEXmlNode* _Nonnull)xmlNode
{
    MXEXmlNode* iterator = xmlNode;
    for (NSString* path in self.separatedPath) {
        iterator = [iterator lookupChild:path];
        if (!iterator) {
            return nil;
        }
    }
    return iterator;
}

- (BOOL)setValue:(MXEXmlNode* _Nonnull)xmlNodeToSet forXmlNode:(MXEMutableXmlNode* _Nonnull)targetXmlNode
{
    if (!self.separatedPath.count) {
        [targetXmlNode setToCopyAllElementsFromXmlNode:xmlNodeToSet];
        return YES;
    }

    NSArray<NSString*>* separatedParentPath = [self.separatedPath subarrayWithRange:NSMakeRange(1, self.separatedPath.count - 1)];
    MXEMutableXmlNode* iterator = targetXmlNode;

    for (NSString* path in separatedParentPath) {
        iterator = (MXEMutableXmlNode*)[iterator lookupChild:path];
        if (!iterator) {
            return NO;
        }
    }

    [iterator removeChildren:[self.separatedPath lastObject]];
    [iterator addChild:xmlNodeToSet];
    return YES;
}

@end
