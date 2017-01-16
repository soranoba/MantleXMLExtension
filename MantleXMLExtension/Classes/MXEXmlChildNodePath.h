//
//  MXEXmlChildNodePath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/23.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlPath.h"
#import <Foundation/Foundation.h>

/**
 * A class for expressing the XML node, out of elements of xml.
 *
 * @see MXEXmlSerializing # xmlKeyPathsByPropertyKey:
 */
@interface MXEXmlChildNodePath : MXEXmlPath

/**
 * Create a node path.
 *
 * e.g.
 *    <object><a key="attribute">value</a></object>
 *
 *    If you specify <a key="attribute">value</a>, use [MXEXmlChildNodePath pathWithNodePath:@"object.a"].
 *
 * @param nodePath NSString* or NSArray<NSString*>*
 *                 Path from root to the specified node.
 * @return instance
 */
- (instancetype _Nonnull)initWithNodePath:(id _Nonnull)nodePath;

/**
 * Create a node path.
 * @see initWithNodePath:
 */
+ (instancetype _Nonnull)pathWithNodePath:(id _Nonnull)nodePath;

@end

/**
 * Short syntax of MXEXmlChildNodePath initializer.
 *
 * @see MXEXmlChildNodePath # initWithNodePath:
 */
static inline MXEXmlChildNodePath* _Nonnull MXEXmlChildNode(id _Nonnull path)
{
    return [MXEXmlChildNodePath pathWithNodePath:path];
}
