//
//  MXEXmlAttributePath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlAttributePath.h"
#import "MXEXmlNodePath.h"

@interface MXEXmlAttributePath ()

/// A path of node that have this attribute.
@property (nonatomic, nonnull, strong) MXEXmlNodePath* nodePath;
/// A specified attribute key.
@property (nonatomic, nonnull, copy) NSString* attributeKey;

@end

@implementation MXEXmlAttributePath

- (instancetype _Nullable)init
{
    NSAssert(NO, @"%@ MUST need to use the designed initializer.", self.class);
    return nil;
}

- (instancetype _Nonnull)initWithPathString:(NSString* _Nonnull)pathString
                               attributeKey:(NSString* _Nonnull)attributeKey
{
    NSParameterAssert(attributeKey != nil && attributeKey.length > 0);

    if (self = [super init]) {
        self.nodePath = [MXEXmlNodePath pathWithPathString:pathString];
        self.attributeKey = attributeKey;
    }
    return self;
}

+ (instancetype _Nonnull)pathWithPathString:(NSString* _Nonnull)pathString
                               attributeKey:(NSString* _Nonnull)attributeKey
{
    return [[self alloc] initWithPathString:pathString attributeKey:attributeKey];
}

#pragma mark - MXEXmlAccessible

- (NSArray<NSString*>* _Nonnull)separatedPath
{
    return self.nodePath.separatedPath;
}

- (NSString* _Nullable)getValueFromXmlNode:(MXEXmlNode* _Nonnull)rootXmlNode
{
    NSParameterAssert(rootXmlNode != nil);

    MXEXmlNode* foundNode = [self.nodePath getValueFromXmlNode:rootXmlNode];
    return foundNode.attributes[self.attributeKey];
}

- (void)setValue:(NSString* _Nullable)value forXmlNode:(MXEMutableXmlNode* _Nonnull)rootXmlNode
{
    NSParameterAssert(rootXmlNode != nil);
    NSParameterAssert(value == nil || [value isKindOfClass:NSString.class]);

    MXEMutableXmlNode* foundNode = [self.nodePath getValueFromXmlNode:rootXmlNode];
    if (foundNode) {
        foundNode.attributes[self.attributeKey] = value;
    } else {
        MXEMutableXmlNode* xmlNodeToSet
            = [[MXEMutableXmlNode alloc] initWithElementName:@"dummy"
                                                  attributes:(value ? @{ self.attributeKey : value } : nil)
                                                       value:nil];
        [self.nodePath setValue:xmlNodeToSet forXmlNode:rootXmlNode];
    }
}

#pragma mark - NSObject (Override)

- (NSString* _Nonnull)description
{
    return [NSString stringWithFormat:@"MXEXmlAttribute(%@, @\"%@\")",
                                      self.nodePath, self.attributeKey];
}

@end
