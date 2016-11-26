//
//  MXEXmlPath+Private.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/23.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlPath.h"

@class MXEXmlNode;

@interface MXEXmlPath ()

/// The node list in order from the parent node.
@property (nonatomic, nonnull, copy) NSArray<NSString*>* separatedPath;

/**
 * Separate node path of character string with dot
 *
 * @param nodePath Path from root to the specified point.
 * @return Separated node path
 */
+ (NSArray<NSString*>* _Nonnull)separateNodePath:(NSString* _Nullable)nodePath;

/**
 * Return blocks getting value from node of path.
 *
 * @return blocks getting value from node.
 */
- (id _Nullable (^_Nonnull)(MXEXmlNode* _Nonnull))getValueBlocks;

/**
 * Return blocks setting value to node of path.
 *
 * @return blocks setting value to node.
 */
- (BOOL (^_Nonnull)(MXEXmlNode* _Nonnull node, id _Nullable value))setValueBlocks;

@end
