//
//  MXEXmlArrayPath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"
#import <Foundation/Foundation.h>

/**
 * A class for expressing the children that has some element name, out of elements of xml.
 *
 * @see MXEXmlSerializing # xmlKeyPathsByPropertyKey:
 */
@interface MXEXmlArrayPath : NSObject <MXEXmlAccessible>

/**
 * Create a children path.
 *
 * e.g.
 *    <object><user>Alice</user><user>Bob</user><user>Carol</user></object>
 *
 *    If you specify all user's value, 
 *    use `[MXEXmlArrayPath pathWithParentPathString:@"object" collectRelativePath:@"user"]`.
 *
 * @param parentPathString     A Path from the root to the parent of the child nodes.
 * @param collectRelativePath  NSString* or id<MXEAccessible>
 *                             Relative path from the parent to the child node.
 * @return instance
 */
- (instancetype _Nonnull)initWithParentPathString:(NSString* _Nonnull)parentPathString
                              collectRelativePath:(id _Nonnull)collectRelativePath;

/**
 * Create a children path.
 *
 * @see initWithParentPathString:collectRelativePath:
 */
+ (instancetype _Nonnull)pathWithParentPathString:(NSString* _Nonnull)parentNodePath
                              collectRelativePath:(id _Nonnull)collectRelativePath;

@end

@interface MXEXmlArrayPath (Deprecated)

- (instancetype _Nonnull)initWithParentNodePath:(id _Nonnull)parentNodePath
                            collectRelativePath:(id _Nonnull)collectRelativePath
    __attribute__((unavailable("Replaced by initWithParentPathString:collectRelativePath:")));

+ (instancetype _Nonnull)pathWithParentNodePath:(id _Nonnull)parentNodePath
                            collectRelativePath:(id _Nonnull)collectRelativePath
    __attribute__((unavailable("Replaced by pathWithParentPathString:collectRelativePath:")));

@end

/**
 * Short syntax of MXEXmlArrayPath initializer
 *
 * @see MXEXmlArrayPath # initWithParentPathString:collectRelativePath:
 */
static inline MXEXmlArrayPath* _Nonnull MXEXmlArray(NSString* _Nonnull parentNodePath, id _Nonnull collectRelativePath)
{
    return [MXEXmlArrayPath pathWithParentPathString:parentNodePath collectRelativePath:collectRelativePath];
}
