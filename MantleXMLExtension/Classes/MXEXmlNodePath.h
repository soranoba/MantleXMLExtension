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

/// The node list in order from the parent node.
@property (nonatomic, nonnull, copy) NSArray<NSString*>* separatedPath;

/**
 * Separate node path of character string with dot
 *
 * @param nodePath Path from root to the specified point.
 * @return Separated node path
 */
+ (NSArray<NSString*>* _Nonnull)separateNodePath:(NSString* _Nullable)nodePath;

@end
