//
//  MXEXmlValuePath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/13.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlValuePath.h"
#import "MXEXmlNodePath.h"

@interface MXEXmlValuePath ()

/// A path of node that have this value.
@property (nonatomic, nonnull, strong) MXEXmlNodePath* nodePath;

@end

@implementation MXEXmlValuePath

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    NSAssert(NO, @"%@ MUST need to use the designed initializer.", self.class);
    return nil;
}

- (instancetype _Nonnull)initWithPathString:(NSString* _Nonnull)pathString
{
    NSParameterAssert(pathString != nil);

    if (self = [super init]) {
        self.nodePath = [MXEXmlNodePath pathWithPathString:pathString];
    }
    return self;
}

+ (instancetype _Nonnull)pathWithPathString:(NSString* _Nonnull)pathString
{
    return [[self alloc] initWithPathString:pathString];
}

#pragma mark - MXEXmlAccessible

- (NSArray<NSString*>* _Nonnull)separatedPath
{
    return self.nodePath.separatedPath;
}

- (id _Nullable)getValueFromXmlNode:(MXEXmlNode* _Nonnull)rootXmlNode
{
    NSParameterAssert(rootXmlNode != nil);

    MXEXmlNode* foundNode = [self.nodePath getValueFromXmlNode:rootXmlNode];
    return foundNode.value;
}

- (void)setValue:(NSString* _Nullable)value forXmlNode:(MXEMutableXmlNode* _Nonnull)rootXmlNode
{
    NSParameterAssert(rootXmlNode != nil);
    NSParameterAssert(value == nil || [value isKindOfClass:NSString.class]);

    MXEMutableXmlNode* foundNode = [self.nodePath getValueFromXmlNode:rootXmlNode];
    if (foundNode) {
        foundNode.value = value;
    } else {
        MXEMutableXmlNode* xmlNodeToSet = [[MXEMutableXmlNode alloc] initWithElementName:@"dummy"
                                                                              attributes:nil
                                                                                   value:value];
        [self.nodePath setValue:xmlNodeToSet forXmlNode:rootXmlNode];
    }
}

#pragma mark - NSObject (Override)

- (NSString* _Nonnull)description
{
    return [NSString stringWithFormat:@"MXEXmlValue(%@)", self.nodePath];
}

@end
