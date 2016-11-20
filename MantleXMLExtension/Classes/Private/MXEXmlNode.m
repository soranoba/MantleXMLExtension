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
+ (NSString* _Nonnull)escapeString:(NSString*)input;

@end
@implementation MXEXmlNode : NSObject

- (instancetype _Nullable)initWithElementName:(NSString* _Nonnull)elementName
{
    if (self = [super init]) {
        self.elementName = elementName;
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

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:self.class]) {
        return [[self toString] isEqualToString:[object toString]];
    }
    return NO;
}

+ (NSString* _Nonnull)escapeString:(NSString*)str
{
    str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    str = [str stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    str = [str stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    return str;
}

@end
