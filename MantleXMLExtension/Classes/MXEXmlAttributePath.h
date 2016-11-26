//
//  MXEXmlAttributePath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlPath.h"
#import <Foundation/Foundation.h>

#define MXEXmlAttribute(_nodePath, _attribute) \
    [MXEXmlAttributePath pathWithNodePath:(_nodePath) attributeKey:(_attribute)]

/**
 * A class for expressing the attribute, out of elements of xml.
 *
 * @see MXEXmlSerializing # xmlKeyPathsByPropertyKey
 */
@interface MXEXmlAttributePath : MXEXmlPath

/**
 * Create a attribute path.
 *
 * e.g.
 *    <object><user name="Alice" /></object>
 *
 *    If you specify user's name.
 *    use [MXEXmlAttributePath pathWithNodePath:@"object.user" attributeKey:@"name"].
 *
 * @param nodePath     NSArray<NSString*>* or NSString*
 *                     Path from root to the specified node that has attribute.
 * @param attributeKey Attribute name.
 * @return instance
 */
- (instancetype _Nonnull)initWithNodePath:(id _Nonnull)nodePath
                             attributeKey:(NSString* _Nonnull)attributeKey;

/**
 * Create a attribute path.
 * @see initWithNodePath:attributeKey:
 */
+ (instancetype _Nonnull)pathWithNodePath:(id _Nonnull)nodePath
                             attributeKey:(NSString* _Nonnull)attributeKey;

@end
