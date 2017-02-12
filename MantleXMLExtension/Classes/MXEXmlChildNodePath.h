//
//  MXEXmlChildNodePath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/23.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlNodePath.h"
#import <Foundation/Foundation.h>

/**
 * A class for expressing the XML node, out of elements of xml.
 * It is a wrapper class overriding to description easier to read.
 *
 * @see MXEXmlNodePath
 */
@interface MXEXmlChildNodePath : MXEXmlNodePath

@end

/**
 * Short syntax of MXEXmlChildNodePath initializer.
 *
 * @see MXEXmlChildNodePath # initWithPathString:
 */
static inline MXEXmlChildNodePath* _Nonnull MXEXmlChildNode(id _Nonnull path)
{
    return [MXEXmlChildNodePath pathWithPathString:path];
}
