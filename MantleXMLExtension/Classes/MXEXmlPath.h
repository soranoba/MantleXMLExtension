//
//  MXEXmlPath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/23.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXEXmlPath : NSObject

/**
 * Create a path
 *
 * e.g.
 *    <object><a>value</a></object>
 *
 *    If you specify value, use [MXEXmlPath pathWithNodePath:@"object.a"].
 *
 * @param nodePath NSString* or NSArray<NSString*>*
 *                 Path from root to the specified value.
 * @return instance
 */
- (instancetype _Nonnull)initWithNodePath:(id _Nonnull)nodePath;

/**
 * Create a path
 * @see initWithNodePath:
 */
+ (instancetype _Nonnull)pathWithNodePath:(id _Nonnull)nodePath;

@end
