//
//  MXEXmlValuePath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/13.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"
#import <Foundation/Foundation.h>

@interface MXEXmlValuePath : NSObject <MXEXmlAccessible>

/**
 * Create a path
 *
 * e.g.
 *    <object><a>value</a></object>
 *
 *    If you specify value, use `[MXEXmlValuePath pathWithPathString:@"object.a"]`.
 *
 * @param pathString  A path from root to the specified value.
 * @return instance
 */
- (instancetype _Nonnull)initWithPathString:(NSString* _Nonnull)pathString;

/**
 * Create a path
 *
 * @see initWithPathString:
 */
+ (instancetype _Nonnull)pathWithPathString:(NSString* _Nonnull)pathString;

@end

@interface MXEXmlPath : NSObject

- (instancetype _Nonnull)initWithNodePath:(id _Nonnull)nodePath
    __attribute__((unavailable("Replaced by MXEXmlValuePath # initWithPathString:")));

+ (instancetype _Nonnull)pathWithNodePath:(id _Nonnull)nodePath
    __attribute__((unavailable("Replaced by MXEXmlValuePath # pathWithPathString:")));

@end

/**
 * Short syntax of MXEXmlValuePath initializer.
 *
 * @see MXEXmlValuePath # initWithPathString:
 */
static inline MXEXmlValuePath* _Nonnull MXEXmlValue(NSString* _Nonnull pathString)
{
    return [MXEXmlValuePath pathWithPathString:pathString];
}
