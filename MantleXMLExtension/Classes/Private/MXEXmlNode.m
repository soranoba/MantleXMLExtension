//
//  MXEXmlNode.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"

@implementation MXEXmlNode

- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
{
    NSParameterAssert(elementName != nil);

    if (self = [super init]) {
        self.elementName = elementName;
        self.attributes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype _Nullable)initWithXmlPath:(MXEXmlPath* _Nonnull)xmlPath value:(id _Nullable)value
{
    NSParameterAssert(xmlPath != nil);

    NSString* elementName = [xmlPath.separatedPath firstObject];
    NSArray<NSString*>* separatedPath;
    if (xmlPath.separatedPath.count > 1) {
        separatedPath = [xmlPath.separatedPath subarrayWithRange:NSMakeRange(1, xmlPath.separatedPath.count - 1)];
    } else {
        separatedPath = [NSArray array];
    }

    if (self = [self initWithElementName:elementName]) {
        MXEXmlNode* iterator = self;
        for (NSString* path in separatedPath) {
            MXEXmlNode* child = [[MXEXmlNode alloc] initWithElementName:path];
            iterator.children = [NSMutableArray array];
            [iterator.children addObject:child];
            iterator = child;
        }
        if (value && ![xmlPath setValueBlocks](iterator, value)) {
            return nil;
        }
    }
    return self;
}

- (void)setChildren:(id _Nullable)children
{
    if ([children isKindOfClass:NSArray.class]) {
        for (id child in children) {
            if (![child isKindOfClass:self.class]) {
                NSAssert(NO, @"Children MUST be array of %@ or NSString. But, array include %@",
                         self.class, [child class]);
            }
        }
    } else if (children) {
        NSAssert([children isKindOfClass:NSString.class],
                 @"Children MUST be array of %@ or NSString. But, got %@", self.class, [children class]);
    }
    _children = children;
}

- (NSString* _Nonnull)toString
{
    NSMutableString* attributesStr = [NSMutableString string];
    for (NSString* key in self.attributes) {
        NSString* appendStr = [NSString stringWithFormat:@" %@=\"%@\"", key,
                                                         [self.class escapeString:self.attributes[key]]];
        [attributesStr appendString:appendStr];
    }

    if (!self.children) {
        return [NSString stringWithFormat:@"<%@%@ />", self.elementName, attributesStr];
    } else if ([self.children isKindOfClass:NSString.class]) {
        return [NSString stringWithFormat:@"<%@%@>%@</%@>", self.elementName, attributesStr,
                                          [self.class escapeString:self.children], self.elementName];
    } else if ([self.children isKindOfClass:NSArray.class]) {
        NSMutableString* childrenStr = [NSMutableString string];
        for (id child in self.children) {
            if ([child isKindOfClass:self.class]) {
                [childrenStr appendString:[child toString]];
            } else {
                NSAssert(NO, @"Children MUST be array of %@ or NSString. But, array include %@",
                         self.class, [child class]);
            }
        }
        return [NSString stringWithFormat:@"<%@%@>%@</%@>", self.elementName, attributesStr, childrenStr,
                                          self.elementName];
    } else {
        NSAssert(NO, @"Children MUST be array of %@ or NSString. But, got %@", self.class, self.children);
        return @"";
    }
}

- (BOOL)isEmpty
{
    return (self.attributes.count == 0 && !self.children);
}

- (MXEXmlNode* _Nullable)lookupChild:(NSString* _Nonnull)nodeName
{
    NSParameterAssert(nodeName != nil);

    if ([self.children isKindOfClass:NSArray.class]) {
        for (id child in self.children) {
            NSAssert([child isKindOfClass:self.class],
                     @"Children is NSString or array of %@, but got %@", self.class, [child class]);
            if ([((MXEXmlNode*)child).elementName isEqualToString:nodeName]) {
                return child;
            }
        }
    }
    return nil;
}

- (id _Nullable)getForXmlPath:(MXEXmlPath* _Nonnull)xmlPath
{
    NSParameterAssert(xmlPath != nil);

    MXEXmlNode* iterator = self;
    for (NSString* path in xmlPath.separatedPath) {
        MXEXmlNode* lookupNode = [iterator lookupChild:path];
        if (lookupNode) {
            iterator = lookupNode;
        } else {
            return nil;
        }
    }
    return [xmlPath getValueBlocks](iterator);
}

- (BOOL)setValue:(id _Nullable)value forXmlPath:(MXEXmlPath* _Nonnull)xmlPath
{
    NSParameterAssert(xmlPath != nil);

    NSArray<NSString*>* separatedPath = xmlPath.separatedPath;

    MXEXmlNode* iterator = self;
    int i;

    for (i = 0; i < separatedPath.count; i++) {
        NSString* path = separatedPath[i];
        MXEXmlNode* lookupNode = [iterator lookupChild:path];
        if (lookupNode) {
            iterator = lookupNode;
        } else {
            break;
        }
    }

    NSArray* notEnoughxmlPath = [separatedPath subarrayWithRange:NSMakeRange(i, separatedPath.count - i)];
    if (!notEnoughxmlPath.count) {
        return [xmlPath setValueBlocks](iterator, value);
    }

    MXEXmlPath* copyPath = [xmlPath copy];
    copyPath.separatedPath = notEnoughxmlPath;
    MXEXmlNode* insertNode = [[self.class alloc] initWithXmlPath:copyPath
                                                           value:value];
    if (!insertNode) {
        return NO;
    }

    if (![iterator.children isKindOfClass:NSMutableArray.class]) {
        if ([iterator.children isKindOfClass:NSArray.class]) {
            iterator.children = [iterator.children mutableCopy];
        } else {
            iterator.children = [NSMutableArray array];
        }
    }
    [iterator.children addObject:insertNode];
    return YES;
}

#pragma mark - NSObject (override)

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class]) {
        return NO;
    }

    MXEXmlNode* node = object;
    if (![node.elementName isEqual:self.elementName]) {
        return NO;
    }

    if (node.attributes.count != self.attributes.count) {
        return NO;
    }
    for (NSString* key in node.attributes) {
        if (![node.attributes[key] isEqual:self.attributes[key]]) {
            return NO;
        }
    }

    if ([node.children isKindOfClass:NSString.class] && [self.children isKindOfClass:NSString.class]) {
        return [node.children isEqual:self.children];
    } else if ([node.children isKindOfClass:NSArray.class] && [self.children isKindOfClass:NSArray.class]) {
        if ([node.children count] != [self.children count]) {
            return NO;
        }
        for (int i = 0; i < [node.children count]; i++) {
            if (![node.children[i] isEqual:self.children[i]]) {
                return NO;
            }
        }
        return YES;
    }
    return node.children == nil && self.children == nil;
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

@end
