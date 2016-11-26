//
//  MXEXmlNode.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"

@interface MXEXmlNode ()

/**
 * XML escape
 *
 * @param str Input string
 * @return escaped string
 */
+ (NSString* _Nonnull)escapeString:(NSString* _Nullable)str;

@end

@implementation MXEXmlNode

- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
{
    if (self = [super init]) {
        self.elementName = elementName;
        self.attributes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype _Nullable)initWithXmlPath:(MXEXmlPath* _Nonnull)xmlPath value:(id _Nullable)value
{
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

- (void)setChildren:(id)children
{
    if ([children isKindOfClass:NSArray.class]) {
        for (id child in children) {
            NSAssert([child isKindOfClass:self.class],
                     @"Children MUST be array of %@ or NSString. But, array include %@", self.class, [child class]);
        }
    } else {
        NSAssert([children isKindOfClass:NSString.class],
                 @"Children MUST be array of %@ or NSString. But, got %@", self.class, [children class]);
    }
    _children = children;
}

- (NSString* _Nonnull)toString
{
    NSMutableString* attributesStr = [NSMutableString string];
    if (self.attributes) {
        for (NSString* key in self.attributes) {
            [attributesStr appendString:[NSString stringWithFormat:@" %@=\"%@\"",
                                                                   key, [self.class escapeString:self.attributes[key]]]];
        }
    }

    if (self.children) {
        if ([self.children isKindOfClass:NSString.class]) {
            return [NSString stringWithFormat:@"<%@%@>%@</%@>",
                                              self.elementName, attributesStr, [self.class escapeString:self.children], self.elementName];
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
            return [NSString stringWithFormat:@"<%@%@>%@</%@>",
                                              self.elementName, attributesStr, childrenStr, self.elementName];
        } else {
            NSAssert(NO, @"Children MUST be array of %@ or NSString. But, got %@", self.class, self.children);
            return @"";
        }
    } else {
        return [NSString stringWithFormat:@"<%@%@ />", self.elementName, attributesStr];
    }
}

- (MXEXmlNode* _Nullable)lookupChild:(NSString* _Nonnull)nodeName
{
    if ([self.children isKindOfClass:NSArray.class]) {
        for (id child in self.children) {
            NSAssert([child isKindOfClass:self.class], @"children is string or array of %@", self.class);
            if ([((MXEXmlNode*)child).elementName isEqualToString:nodeName]) {
                return child;
            }
        }
    }
    return nil;
}

- (id _Nullable)getForXmlPath:(MXEXmlPath* _Nonnull)xmlPath
{
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

- (BOOL)setValue:(id _Nonnull)value forXmlPath:(MXEXmlPath* _Nonnull)xmlPath
{
    NSArray<NSString*>* separatedPath = xmlPath.separatedPath;

    MXEXmlNode* iterator = self;
    BOOL doFound = YES;
    int i;

    for (i = 0; i < separatedPath.count; i++) {
        NSString* path = separatedPath[i];
        MXEXmlNode* lookupNode = [iterator lookupChild:path];
        if (lookupNode) {
            iterator = lookupNode;
        } else {
            doFound = NO;
            break;
        }
    }

    if (doFound) {
        return [xmlPath setValueBlocks](iterator, value);
    } else {
        NSArray* notEnoughxmlPath = [separatedPath subarrayWithRange:NSMakeRange(i, separatedPath.count - i)];

        xmlPath.separatedPath = notEnoughxmlPath;
        MXEXmlNode* insertNode = [[self.class alloc] initWithXmlPath:xmlPath
                                                               value:value];
        xmlPath.separatedPath = separatedPath;

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
