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
 * Escape double quotations with backslash.
 *
 * @param attributeStr Input string.
 * @return escaped string
 */
+ (NSString* _Nonnull)escapeAttributeString:(NSString*)attributeStr;

@end
@implementation MXEXmlNode : NSObject

- (instancetype _Nullable)initWithElementName:(NSString* _Nonnull)elementName
{
    if (self = [super init]) {
        self.elementName = elementName;
    }
    return self;
}

- (NSString* _Nonnull)toString
{
    NSMutableString* attributesStr = [NSMutableString string];
    if (self.attributes) {
        for (NSString* key in self.attributes) {
            [attributesStr appendString:[NSString stringWithFormat:@" %@=\"%@\"",
                                        key, [self.class escapeAttributeString:self.attributes[key]]]];
        }
    }
    if (self.children) {
        NSMutableString* childrenStr = [NSMutableString string];
        for (id child in self.children) {
            if ([child isKindOfClass:NSString.class]) {
                [childrenStr appendString:child];
            } else if ([child isKindOfClass:self.class]) {
                [childrenStr appendString:[child toString]];
            } else {
                NSAssert(NO, @"Children MUST be array of NSString or MXEXmlNode");
            }
        }
        return [NSString stringWithFormat:@"<%@%@>%@</%@>",
                self.elementName, attributesStr, childrenStr, self.elementName];
    } else {
        return [NSString stringWithFormat:@"<%@%@ />", self.elementName, attributesStr];
    }
}

+ (NSString* _Nonnull)escapeAttributeString:(NSString*)attributeStr
{
    return [attributeStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

@end
