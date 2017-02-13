//
//  MXEXmlArrayPath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlArrayPath.h"
#import "MXEXmlNode.h"
#import "MXEXmlNodePath.h"
#import "MXEXmlValuePath.h"

@interface MXEXmlArrayPath ()

@property (nonatomic, nonnull, strong) MXEXmlNodePath* parentNodePath;
@property (nonatomic, nonnull, strong) id<MXEXmlAccessible> collectRelativePath;

@end

@implementation MXEXmlArrayPath

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithParentPathString:(NSString* _Nonnull)parentPathString
                              collectRelativePath:(id _Nonnull)collectRelativePath
{
    NSParameterAssert(parentPathString != nil && collectRelativePath != nil);

    if (self = [super init]) {
        self.parentNodePath = [MXEXmlNodePath pathWithPathString:parentPathString];
        if ([collectRelativePath conformsToProtocol:@protocol(MXEXmlAccessible)]) {
            self.collectRelativePath = collectRelativePath;
        } else {
            NSAssert([collectRelativePath isKindOfClass:NSString.class],
                     @"collectRelativePath MUST be NSString or MXEXmlAccessible object");
            self.collectRelativePath = MXEXmlValue(collectRelativePath);
        }
    }
    return self;
}

+ (instancetype _Nonnull)pathWithParentPathString:(NSString* _Nonnull)parentNodePath
                              collectRelativePath:(id _Nonnull)collectRelativePath
{
    return [[self alloc] initWithParentPathString:parentNodePath
                              collectRelativePath:collectRelativePath];
}

#pragma mark - MXEXmlAccessible

- (NSArray<NSString*>* _Nonnull)separatedPath
{
    return self.parentNodePath.separatedPath;
}

- (id _Nullable)getValueFromXmlNode:(MXEXmlNode* _Nonnull)rootXmlNode
{
    NSParameterAssert(rootXmlNode != nil);

    MXEXmlNode* foundNode = [self.parentNodePath getValueFromXmlNode:rootXmlNode];
    if (!foundNode) {
        return nil;
    }

    NSMutableArray* resultArray = [NSMutableArray array];
    for (MXEXmlNode* child in foundNode.children) {
        MXEXmlNode* dummyNode;
        if (child == [foundNode.children firstObject]) {
            // NOTE: It should have attribute for the first time only, so it use original attributes.
            dummyNode = [[MXEXmlNode alloc] initWithElementName:foundNode.elementName
                                                     attributes:foundNode.attributes
                                                       children:@[ child ]];
        } else {
            dummyNode = [[MXEXmlNode alloc] initWithElementName:foundNode.elementName
                                                     attributes:nil
                                                       children:@[ child ]];
        }

        id foundValue = [self.collectRelativePath getValueFromXmlNode:dummyNode];
        if (foundValue) {
            [resultArray addObject:foundValue];
        }
    }
    return resultArray;
}

- (void)setValue:(NSArray* _Nullable)values forXmlNode:(MXEMutableXmlNode* _Nonnull)rootXmlNode
{
    NSParameterAssert(rootXmlNode != nil);
    NSParameterAssert(values == nil || [values isKindOfClass:NSArray.class]);

    MXEMutableXmlNode* foundNode = [self.parentNodePath getValueFromXmlNode:rootXmlNode];
    if (!foundNode) {
        foundNode = [[MXEMutableXmlNode alloc] initWithElementName:@"dummy"];
        [self.parentNodePath setValue:foundNode forXmlNode:rootXmlNode];
    }

    NSUInteger index = 0;
    NSString* searchChildName = [self.collectRelativePath.separatedPath firstObject];

    for (MXEMutableXmlNode* child in foundNode.children) {
        if (!(searchChildName == nil || [searchChildName isEqualToString:child.elementName])) {
            continue;
        }

        if (index >= values.count) {
            break;
        }

        MXEMutableXmlNode* dummyNode;
        if (child == [foundNode.children firstObject]) {
            // NOTE: It should have attribute for the first time only, so it use original attributes.
            dummyNode = [[MXEMutableXmlNode alloc] initWithElementName:foundNode.elementName
                                                            attributes:foundNode.attributes
                                                              children:@[ child ]];
        } else {
            dummyNode = [[MXEMutableXmlNode alloc] initWithElementName:foundNode.elementName
                                                            attributes:nil
                                                              children:@[ child ]];
        }

        [self.collectRelativePath setValue:values[index] forXmlNode:dummyNode];
        index++;
    }

    for (; index < values.count; index++) {
        MXEMutableXmlNode* dummyNode = [[MXEMutableXmlNode alloc] initWithElementName:@"dummy"];
        [self.collectRelativePath setValue:values[index] forXmlNode:dummyNode];
        if (dummyNode.children.count) {
            [foundNode addChild:dummyNode.children[0]];
        }
    }
}

#pragma mark - NSObject (Override)

- (NSString* _Nonnull)description
{
    return [NSString stringWithFormat:@"MXEXmlArray(%@, %@)", self.parentNodePath, self.collectRelativePath];
}

@end
