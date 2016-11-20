//
//  MXEXmlMultiNodesPath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A class for expressing children that has some element name, out of elements of xml.
 *
 * @see MXEXmlSerializing +xmlKeyPathsByPropertyKey
 */
@interface MXEXmlMultiNodesPath : NSObject

/**
 * @param parentPath
 * @param pathToBeCollected A path is relative path from parent path.
 */
- (instancetype _Nullable) initWithParentPaths: (NSArray<NSString*>* _Nonnull)parentPath
                            pathsToBeCollected: (NSArray<NSString*>* _Nonnull)pathToBeCollected;

@end
