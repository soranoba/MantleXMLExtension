//
//  MXEXmlAttributePath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MXEXmlAttribute(nodePath, attribute) \
    [MXEXmlAttributePath pathWithNode:(nodePath) attributeKey:(attribute)]

/**
 * A class for expressing attribute, out of elements of xml.
 *
 * @see MXEXmlSerializing +xmlKeyPathsByPropertyKey
 */
@interface MXEXmlAttributePath : NSObject

/**
 * Create a attribute path.
 *
 * @param nodePath     A path of node that has the attribute.
 *                     When specifying a grandchild node, the path is `parent.child.grandchild`.
 *                     When specifying a root node, the path is nil or empty string or `.`.
 * @param attributeKey Attribute name.
 * @return instance
 */
- (instancetype _Nullable) initWithNodePath: (NSString* _Nullable)nodePath
                               attributeKey: (NSString* _Nonnull)attributeKey;

+ (instancetype _Nullable) pathWithNode: (NSString* _Nullable)nodePath
                           attributeKey: (NSString* _Nonnull)attributeKey;

@end
