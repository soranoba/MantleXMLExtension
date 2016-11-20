//
//  MXEXmlDuplicateNodesPath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MXEXmlDuplicateNodes(nodePath, collectPath) \
    [MXEXmlDuplicateNodesPath pathWithParentNode:(nodePath) collectRelative:(collectPath)]

/**
 * A class for expressing children that has some element name, out of elements of xml.
 *
 * @see MXEXmlSerializing +xmlKeyPathsByPropertyKey
 */
@interface MXEXmlDuplicateNodesPath : NSObject

/**
 * Create duplicate node path.
 *
 * @param parentNodePath       Its path has duplicate nodes.
 *                             When specifying a root node, the path is nil or empty string or `.`.
 * @param collectRelativePath  Search this path on parentNodePath and create array.
 *                             The corresponding property MUST be an array.
 */
- (instancetype _Nullable) initWithParentNodePath: (NSString* _Nullable)parentNodePath
                              collectRelativePath: (NSString* _Nonnull)collectRelativePath;

+ (instancetype _Nullable) pathWithParentNode: (NSString* _Nullable)parentNodePath
                              collectRelative: (NSString* _Nonnull)collectRelativePath;

@end
