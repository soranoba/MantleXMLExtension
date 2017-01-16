//
//  MXEXmlArrayPath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlPath.h"
#import <Foundation/Foundation.h>

/**
 * A class for expressing the children that has some element name, out of elements of xml.
 *
 * @see MXEXmlSerializing # xmlKeyPathsByPropertyKey:
 */
@interface MXEXmlArrayPath : MXEXmlPath

/**
 * Create a children path.
 *
 * e.g.
 *    <object><user>Alice</user><user>Bob</user><user>Carol</user></object>
 *
 *    If you specify all user's value, 
 *    use [MXEXmlArrayPath pathWithParentNodePath:@"object" collectRelativePath:@"user"].
 *
 * @param parentNodePath       NSString* or NSArray<NSString*>*
 *                             Path from the root to the parent of the child nodes.
 * @param collectRelativePath  NSString* or NSArray<NSString*>* or MXEXmlPath*
 *                             Relative path from the parent to the child node.
 */
- (instancetype _Nonnull)initWithParentNodePath:(id _Nonnull)parentNodePath
                            collectRelativePath:(id _Nonnull)collectRelativePath;

/**
 * Create a children path.
 * @see initWithParentNodePath:collectRelativePath:
 */
+ (instancetype _Nonnull)pathWithParentNodePath:(id _Nonnull)parentNodePath
                            collectRelativePath:(id _Nonnull)collectRelativePath;

@end

/**
 * Short syntax of MXEXmlArrayPath initializer
 *
 * @see MXEXmlArrayPath # initWithParentNodePath:collectRelativePath:
 */
static inline MXEXmlArrayPath* _Nonnull MXEXmlArray(id _Nonnull parentNodePath, id _Nonnull collectRelativePath)
{
    return [MXEXmlArrayPath pathWithParentNodePath:parentNodePath collectRelativePath:collectRelativePath];
}
