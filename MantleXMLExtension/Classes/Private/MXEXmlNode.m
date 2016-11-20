//
//  MXEXmlNode.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"

@interface MXEXmlNode()

/**
 * Escape.
 *
 * @param input Input string.
 * @return escaped string
 */
+ (NSString* _Nonnull)escapeString:(NSString* _Nullable)input;

- (MXEXmlNode* _Nullable)lookupChild:(NSString*)elementName;
+ (NSArray<NSString*>* _Nonnull)stringPathToArrayPath:(NSString*)path;

@end
@implementation MXEXmlNode : NSObject

- (instancetype _Nullable)initWithElementName:(NSString* _Nonnull)elementName
{
    if (self = [super init]) {
        self.elementName = elementName;
    }
    return self;
}

- (instancetype _Nullable) initWithKeyPath:(id _Nonnull)keyPath
{
    return [self initWithKeyPath:keyPath blocks:nil];
}

- (instancetype _Nullable) initWithKeyPath:(id _Nonnull)keyPath value:(NSString* _Nullable)value
{
    return [self initWithKeyPath:keyPath
                          blocks:^(MXEXmlNode* _Nonnull node) {
                              node.children = value;
                          }];
}

- (instancetype _Nullable) initWithKeyPath:(id _Nonnull)keyPath
                                    blocks:(MXEXmlNodeInsertBlock _Nullable)blocks
{
    NSParameterAssert(keyPath != nil);

    if (self = [super init]) {
        if ([keyPath isKindOfClass:NSString.class]) {
            keyPath = [self.class stringPathToArrayPath:keyPath];
        } else if (![keyPath isKindOfClass:NSArray.class]) {
            NSAssert(NO, @"KeyPath MUST be NSArray or NSString. But got %@", [keyPath class]);
            return nil;
        }

        if (((NSArray*)keyPath).count == 0) {
            return nil;
        }

        MXEXmlNode* iterator = self;
        for (id path in (NSArray<id>*)keyPath) {
            NSAssert([path isKindOfClass:NSString.class],
                     @"KeyPath MUST be array of NSString or NSString. But array included %@", [path class]);
            if (!iterator.elementName) {
                iterator.elementName = path;
            } else {
                MXEXmlNode* child = [[MXEXmlNode alloc] initWithElementName:path];
                if (!child) {
                    return nil;
                }
                iterator.children = [NSMutableArray array];
                [iterator.children addObject:child];
                iterator = child;
            }
        }
        if (blocks) {
            blocks(iterator);
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
        } else if ([self.children isKindOfClass:NSArray.class]){
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

- (id _Nullable)getChildForKeyPath:(id _Nonnull)keyPath
{
    if ([keyPath isKindOfClass:MXEXmlAttributePath.class]) {

        MXEXmlAttributePath* attribute = keyPath;
        NSMutableArray<NSString*>* pathArray = [[self.class stringPathToArrayPath:attribute.nodePath] mutableCopy];

        if (!pathArray.count || (pathArray.count == 1 && !(pathArray[0].length))) {
            return self.attributes[attribute.attributeKey];
        } else {
            NSString* elementName = [pathArray lastObject];
            [pathArray removeLastObject];

            MXEXmlNode* tmp = [[MXEXmlNode alloc] initWithElementName:@""];
            tmp.children = [self getChildForKeyPath:pathArray];
            return [tmp lookupChild:elementName].attributes[attribute.attributeKey];
        }

    } else if ([keyPath isKindOfClass:MXEXmlDuplicateNodesPath.class]) {

        MXEXmlDuplicateNodesPath* nodePath = keyPath;
        id searchNodes = [self getChildForKeyPath:nodePath.parentNodePath];
        if ([searchNodes isKindOfClass:NSArray.class]) {
            NSMutableArray* result = [NSMutableArray array];
            for (id child in searchNodes) {
                if ([child isKindOfClass:self.class]) {
                    MXEXmlNode* tmp = [[MXEXmlNode alloc] initWithElementName:@""];
                    tmp.children = @[child];
                    id foundNode = [tmp getChildForKeyPath:nodePath.collectRelativePath];
                    if (foundNode) {
                        [result addObject:foundNode];
                    }
                }
            }
            return result;
        }
        return nil;

    } else if ([keyPath isKindOfClass:NSString.class]) {
        keyPath = [self.class stringPathToArrayPath:keyPath];
    } else {
        NSAssert([keyPath isKindOfClass:NSArray.class],
                 @"keyPath MUST be NSString or NSArray or MXEXmlAttributePath or MXEXmlDuplicateNodesPath");
    }

    MXEXmlNode* iterator = self;
    for (NSString* path in keyPath) {
        MXEXmlNode* lookupNode = [iterator lookupChild:path];
        if (lookupNode) {
            iterator = lookupNode;
        } else {
            return nil;
        }
    }
    return iterator.children;
}

- (void)setChildWithBlocks:(MXEXmlNodeInsertBlock _Nonnull)blocks forKeyPath:(id _Nonnull)keyPath
{
    if ([keyPath isKindOfClass:MXEXmlAttributePath.class]) {

        MXEXmlAttributePath* attribute = keyPath;
        [self setChildWithBlocks:blocks forKeyPath:attribute.nodePath];
        return;

    } else if ([keyPath isKindOfClass:MXEXmlDuplicateNodesPath.class]) {

        MXEXmlDuplicateNodesPath* nodePath = keyPath;
        MXEXmlNode* insertNode = [[self.class alloc] initWithKeyPath:nodePath.collectRelativePath
                                                              blocks:blocks];
        if (insertNode) {
            [self setChildWithBlocks:^(MXEXmlNode* _Nonnull node) {
                if (!node.children) {
                    node.children = [NSMutableArray array];
                }
                [node.children addObject:insertNode];
            } forKeyPath:nodePath.parentNodePath];
        }
        return;

    } else if ([keyPath isKindOfClass:NSString.class]) {
        keyPath = [self.class stringPathToArrayPath:keyPath];
    } else {
        NSAssert([keyPath isKindOfClass:NSArray.class],
                 @"keyPath MUST be NSString or NSArray or MXEXmlAttributePath or MXEXmlDuplicateNodesPath");
    }

    MXEXmlNode* iterator = self;
    BOOL doFound = YES;
    int i;

    for (i = 0; i < ((NSArray<NSString*>*)keyPath).count; i++) {
        NSString* path = keyPath[i];
        MXEXmlNode* lookupNode = [iterator lookupChild:path];
        if (lookupNode) {
            iterator = lookupNode;
        } else {
            doFound = NO;
            break;
        }
    }

    if (doFound) {
        blocks(iterator);
    } else {
        NSArray* notEnoughKeyPath = [(NSArray*)keyPath subarrayWithRange:NSMakeRange(i, [keyPath count] - i)];

        MXEXmlNode* insertNode = [[self.class alloc] initWithKeyPath:notEnoughKeyPath
                                                              blocks:blocks];
        if (!insertNode) {
            return;
        }
        if (!iterator.children) {
            iterator.children = [NSMutableArray array];
        }
        [iterator.children addObject:insertNode];
    }
}

- (void)setChild:(NSString* _Nonnull)value forKeyPath:(id _Nonnull)keyPath
{
    if ([keyPath isKindOfClass:MXEXmlAttributePath.class]) {
        MXEXmlAttributePath* attribute = keyPath;
        [self setChildWithBlocks:^(MXEXmlNode* _Nonnull node) {
            if (!node.attributes) {
                node.attributes = [NSMutableDictionary dictionary];
            }
            ((NSMutableDictionary*)node.attributes)[attribute.attributeKey] = value;
        } forKeyPath: attribute.nodePath];
    } else {
        [self setChildWithBlocks:^(MXEXmlNode* _Nonnull node) {
            node.children = value;
        } forKeyPath:keyPath];
    }
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:self.class]) {
        return [[self toString] isEqualToString:[object toString]];
    }
    return NO;
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

- (MXEXmlNode* _Nullable)lookupChild:(NSString*)elementName
{
    if ([self.children isKindOfClass:NSArray.class]) {
        for (id child in self.children) {
            NSAssert([child isKindOfClass:self.class], @"children is string or array of %@", self.class);
            if ([((MXEXmlNode*)child).elementName isEqualToString:elementName]) {
                return child;
            }
        }
    }
    return nil;
}

+ (NSArray<NSString*>* _Nonnull)stringPathToArrayPath:(NSString*)path
{
    NSArray<NSString*>* array = [path componentsSeparatedByString:@"."];
    NSMutableArray<NSString*>* result = [NSMutableArray array];
    for (NSString* p in array) {
        if (p.length) {
            [result addObject:p];
        }
    }
    return result;
}

@end
