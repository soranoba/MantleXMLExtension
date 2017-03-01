//
//  MXEXmlNode.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"

@implementation MXEXmlNode {
@protected
    NSString* _elementName;
    NSDictionary<NSString*, NSString*>* _attributes;
    NSArray<MXEXmlNode*>* _children;
    NSString* _value;
}

@synthesize attributes = _attributes;
@synthesize children = _children;

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
{
    return [self initWithElementName:elementName attributes:nil children:nil];
}

- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
                                  attributes:(NSDictionary<NSString*, NSString*>* _Nullable)attributes
                                    children:(id _Nullable)children
{
    NSParameterAssert(elementName != nil);

    if (self = [super init]) {
        _elementName = [elementName copy];
        _attributes = attributes ? [attributes copy] : [NSDictionary dictionary];
        _children = [children copy];
    }
    return self;
}

- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
                                  attributes:(NSDictionary<NSString*, NSString*>* _Nullable)attributes
                                       value:(NSString* _Nullable)value
{
    NSParameterAssert(elementName != nil);

    if (self = [self initWithElementName:elementName attributes:attributes children:nil]) {
        _value = [value copy];
    }
    return self;
}

- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
                              fromDictionary:(NSDictionary<NSString*, id>* _Nonnull)dictionary
{
    NSParameterAssert(elementName != nil && dictionary != nil);

    NSMutableDictionary<NSString*, NSString*>* attributes = [NSMutableDictionary dictionary];
    NSMutableArray<MXEXmlNode*>* children = [NSMutableArray array];
    BOOL hasValue = dictionary[@""] != nil;

    for (NSString* key in dictionary) {
        id value = dictionary[key];

        if ([key hasPrefix:@"@"]) {
            if (![value isKindOfClass:NSString.class]) {
                NSAssert(NO, @"attribute value only support NSString. but got %@", [value class]);
                continue;
            }
            attributes[[key substringFromIndex:1]] = value;
        } else if (hasValue) {
            NSAssert([key isEqualToString:@""], @"%@ can not have both children and value", self.class);
            continue;
        } else if ([value isKindOfClass:NSString.class]) {
            [children addObject:[[MXEXmlNode alloc] initWithElementName:key attributes:nil value:value]];
        } else if ([value isKindOfClass:NSDictionary.class]) {
            [children addObject:[[MXEXmlNode alloc] initWithElementName:key fromDictionary:value]];
        } else if ([value isEqual:NSNull.null]) {
            [children addObject:[[MXEXmlNode alloc] initWithElementName:key]];
        } else {
            NSAssert(NO, @"value of dictionary only support NSDictionary or NSString, NSNull. but got %@", [value class]);
            continue;
        }
    }

    if (hasValue) {
        return [self initWithElementName:elementName attributes:attributes value:dictionary[@""]];
    } else {
        return [self initWithElementName:elementName attributes:attributes children:children];
    }
}

#pragma mark - Custom Accessor

- (NSDictionary<NSString*, NSString*>* _Nonnull)attributes
{
    return [_attributes copy];
}

- (NSArray<MXEXmlNode*>* _Nullable)children
{
    return [_children copy];
}

- (BOOL)hasChildren
{
    return _children != nil;
}

#pragma mark - Public Methods

- (NSString* _Nonnull)toString
{
    NSMutableString* attributesStr = [NSMutableString string];
    for (NSString* key in self.attributes) {
        NSString* appendStr = [NSString stringWithFormat:@" %@=\"%@\"", key,
                                                         [self.class escapeString:self.attributes[key]]];
        [attributesStr appendString:appendStr];
    }

    if (self.value) {
        return [NSString stringWithFormat:@"<%@%@>%@</%@>", self.elementName, attributesStr,
                                          [self.class escapeString:self.value], self.elementName];
    } else if (self.children.count) {
        NSMutableString* childrenStr = [NSMutableString string];
        for (MXEXmlNode* child in self.children) {
            [childrenStr appendString:[child toString]];
        }
        return [NSString stringWithFormat:@"<%@%@>%@</%@>", self.elementName, attributesStr, childrenStr,
                                          self.elementName];
    } else {
        return [NSString stringWithFormat:@"<%@%@ />", self.elementName, attributesStr];
    }
}

- (NSDictionary<NSString*, id>* _Nonnull)toDictionary
{
    NSMutableDictionary<NSString*, id>* dict = [NSMutableDictionary dictionary];

    for (NSString* attributeKey in self.attributes) {
        NSString* key = [NSString stringWithFormat:@"@%@", attributeKey];
        dict[key] = self.attributes[attributeKey];
    }

    for (MXEXmlNode* child in self.children) {
        if (dict[child.elementName]) {
            continue;
        }

        NSDictionary* childDict = [child toDictionary];
        if (childDict.count == 1 && childDict[@""] != nil) {
            dict[child.elementName] = childDict[@""];
        } else if (childDict.count == 0) {
            dict[child.elementName] = NSNull.null;
        } else {
            dict[child.elementName] = childDict;
        }
    }

    if (self.value) {
        dict[@""] = self.value;
    }

    return dict;
}

- (BOOL)isEmpty
{
    return (self.attributes.count == 0 && !self.children && !self.value);
}

- (MXEXmlNode* _Nullable)lookupChild:(NSString* _Nonnull)elementName
{
    NSParameterAssert(elementName != nil);

    for (MXEXmlNode* child in self.children) {
        if ([child.elementName isEqualToString:elementName]) {
            return child;
        }
    }
    return nil;
}

- (id _Nullable)getForXmlPath:(id<MXEXmlAccessible> _Nonnull)xmlPath
{
    NSParameterAssert(xmlPath != nil);

    return [xmlPath getValueFromXmlNode:self];
}

#pragma mark - Private methods

/**
 * XML escape
 *
 * @param str Input string
 * @return escaped string
 */
+ (NSString* _Nonnull)escapeString:(NSString* _Nullable)str
{
    str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    str = [str stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    str = [str stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    return str;
}

#pragma mark - NSCopying

- (id _Nonnull)copyWithZone:(NSZone* _Nullable)zone
{
    typeof(self) copyNode = [[self.class allocWithZone:zone] initWithElementName:self.elementName];
    if (copyNode) {
        copyNode->_attributes = [self.attributes copyWithZone:zone];
        copyNode->_children = [self.children copyWithZone:zone];
        copyNode->_value = [self.value copyWithZone:zone];
    }
    return copyNode;
}

#pragma mark - NSMutableCopying

- (MXEMutableXmlNode* _Nonnull)mutableCopyWithZone:(NSZone* _Nullable)zone
{
    MXEMutableXmlNode* copyNode = [[MXEMutableXmlNode allocWithZone:zone] initWithElementName:self.elementName];
    if (copyNode) {
        [copyNode setToCopyAllElementsFromXmlNode:self];
    }
    return copyNode;
}

#pragma mark - NSObject (Override)

- (NSString* _Nonnull)description
{
    return [NSString stringWithFormat:@"%@ # %@", self.class, self.toString];
}

- (BOOL)isEqual:(id _Nullable)object
{
    if (![object isKindOfClass:MXEXmlNode.class]) {
        return NO;
    }

    MXEXmlNode* node = object;
    return [node.elementName isEqual:self.elementName]
        && [node.attributes isEqual:self.attributes]
        && (node.children == self.children || [node.children isEqual:self.children])
        && (node.value == self.value || [node.value isEqual:self.value]);
}

@end

@implementation MXEMutableXmlNode

@dynamic elementName;
@dynamic value;

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
{
    return [self initWithElementName:elementName attributes:nil children:nil];
}

- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
                                  attributes:(NSDictionary<NSString*, NSString*>* _Nullable)attributes
                                    children:(NSArray<MXEXmlNode*>* _Nullable)children
{
    NSParameterAssert(elementName != nil);

    if (self = [super init]) {
        _elementName = [elementName copy];
        if ([attributes isKindOfClass:NSMutableDictionary.class]) {
            _attributes = attributes;
        } else {
            _attributes = attributes ? [attributes mutableCopy] : [NSMutableDictionary dictionary];
        }
        _children = [children mutableCopy];
    }
    return self;
}

- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
                                  attributes:(NSDictionary<NSString*, NSString*>* _Nullable)attributes
                                       value:(NSString* _Nullable)value
{
    NSParameterAssert(elementName != nil);

    if (self = [self initWithElementName:elementName attributes:attributes children:nil]) {
        _value = [value copy];
    }
    return self;
}

#pragma mark - Custom Accessor

- (void)setElementName:(NSString* _Nonnull)elementName
{
    NSParameterAssert(elementName != nil);
    _elementName = elementName;
}

- (NSMutableDictionary<NSString*, NSString*>* _Nonnull)attributes
{
    return (NSMutableDictionary*)_attributes;
}

- (void)setAttributes:(NSMutableDictionary<NSString*, NSString*>* _Nonnull)attributes
{
    NSParameterAssert(attributes != nil);
    _attributes = attributes;
}

- (NSMutableArray<MXEMutableXmlNode*>* _Nullable)children
{
    return (NSMutableArray<MXEMutableXmlNode*>*)_children;
}

- (void)setChildren:(NSMutableArray<MXEMutableXmlNode*>* _Nullable)children
{
    _children = children;
    _value = nil;
}

- (void)setValue:(NSString* _Nullable)value
{
    _children = nil;
    _value = value;
}

#pragma mark - Public Methods

- (void)addChild:(MXEXmlNode* _Nonnull)childNode
{
    NSParameterAssert(childNode != nil);

    MXEMutableXmlNode* mutableChildNode;
    if ([childNode isKindOfClass:MXEMutableXmlNode.class]) {
        mutableChildNode = (MXEMutableXmlNode*)childNode;
    } else {
        mutableChildNode = [childNode mutableCopy];
    }

    NSMutableArray* children = self.children ?: [NSMutableArray array];
    [children addObject:mutableChildNode];
    self.children = children;
}

- (void)setToCopyAllElementsFromXmlNode:(MXEXmlNode* _Nonnull)sourceXmlNode
{
    NSParameterAssert(sourceXmlNode != nil);

    self.elementName = sourceXmlNode.elementName;
    self.attributes = [sourceXmlNode.attributes mutableCopy];
    if (sourceXmlNode.hasChildren) {
        self.children = nil;
        for (MXEXmlNode* child in sourceXmlNode.children) {
            [self addChild:child];
        }
    } else {
        self.value = sourceXmlNode.value;
    }
}

- (void)setValue:(id _Nullable)value forXmlPath:(id<MXEXmlAccessible> _Nonnull)xmlPath
{
    NSParameterAssert(xmlPath != nil);
    [xmlPath setValue:value forXmlNode:self];
}

#pragma mark - NSMutableCopying

- (instancetype _Nonnull)mutableCopyWithZone:(NSZone* _Nullable)zone
{
    return [super copyWithZone:zone];
}

@end
