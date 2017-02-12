//
//  MXEXmlAttributePath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"
#import <Foundation/Foundation.h>

/**
 * A class for expressing the attribute, out of elements of xml.
 *
 * @see MXEXmlSerializing # xmlKeyPathsByPropertyKey
 */
@interface MXEXmlAttributePath : NSObject <MXEXmlAccessible>

/**
 * Create a attribute path.
 *
 * e.g.
 *    <object><user name="Alice" /></object>
 *
 *    If you specify user's name.
 *    use `[MXEXmlAttributePath pathWithPathString:@"object.user" attributeKey:@"name"]`.
 *
 * @param pathString   A path from root to the specified node that has attribute.
 * @param attributeKey Attribute name.
 * @return instance
 */
- (instancetype _Nonnull)initWithPathString:(NSString* _Nonnull)pathString
                               attributeKey:(NSString* _Nonnull)attributeKey;

/**
 * Create a attribute path.
 * @see initWithPathString:attributeKey:
 */
+ (instancetype _Nonnull)pathWithPathString:(id _Nonnull)nodePath
                               attributeKey:(NSString* _Nonnull)attributeKey;

@end

/**
 * Short syntax of MXEXmlAttributePath initializer
 *
 * @see MXEXmlAttributePath # initWithPathString:attributeKey:
 */
static inline MXEXmlAttributePath* _Nonnull MXEXmlAttribute(NSString* _Nonnull nodePath, NSString* _Nonnull attributeKey)
{
    return [MXEXmlAttributePath pathWithPathString:nodePath attributeKey:attributeKey];
}
