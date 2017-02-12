//
//  MXEXmlNodePath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/12.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNode.h"
#import <Foundation/Foundation.h>

@interface MXEXmlNodePath : NSObject <MXEXmlAccessible>

#pragma mark - Lifecycle

/**
 * Create a node path.
 *
 * e.g.
 *    <object><a key="attribute">value</a></object>
 *
 *    If you specify `<a key="attribute">value</a>`, use `[MXEXmlNodePath pathWithPathString:@"object.a"]`.
 *
 * @param pathString  A path from root to the specified node.
 * @return instance
 */
- (instancetype _Nonnull)initWithPathString:(NSString* _Nonnull)pathString;

/**
 * Create a node path.
 *
 * @see initWithNodePath:
 */
+ (instancetype _Nonnull)pathWithPathString:(NSString* _Nonnull)pathString;

#pragma mark - Public Methods

/**
 * Separate node path of character string with dot
 *
 * @param pathString Path from root to the specified point.
 * @return Separated node path
 */
+ (NSArray<NSString*>* _Nonnull)separatePathString:(NSString* _Nullable)pathString;

@end
