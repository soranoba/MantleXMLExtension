//
//  MXEXmlAttributePath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A class for expressing attribute, out of elements of xml.
 *
 * @see MXEXmlSerializing +xmlKeyPathsByPropertyKey
 */
@interface MXEXmlAttributePath : NSObject

/**
 * Create a representation of the path whose last path is the attribute.
 *
 * @param paths A list of xml nodes
 * @return instance
 */
- (instancetype _Nullable) initWithPaths: (NSArray<NSString*>* _Nonnull)paths;

/**
 * Create a representation of the path is a root attribute.
 *
 * @param attribute Attribute name
 * @return instance
 */
- (instancetype _Nullable) initWithRootAttribute: (NSString* _Nonnull)attribute;

@end
