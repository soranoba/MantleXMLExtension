//
//  MXEXmlParser.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/25.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEErrorCode.h"
#import "MXEXmlNode.h"
#import <Foundation/Foundation.h>

/**
 * The class support to convertion between NSData and MXEXmlNode.
 */
@interface MXEXmlParser : NSObject

#pragma mark - Public Methods

/**
 * Convert MXEXmlNode to NSData using default xml declaration.
 *
 * @param xmlNode   An input xml node.
 * @param error     If it return nil, error information is saved here.
 * @return If conversion is success, it returns converted data. Otherwise, return nil.
 */
+ (NSData* _Nullable)dataWithXmlNode:(MXEXmlNode* _Nonnull)xmlNode
                               error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert MXEXmlNode to NSData using the xmlDeclaration.
 *
 * @param xmlNode          An input xml node.
 * @param xmlDeclaration   A xml declaration.
 * @param error            If it return nil, error information is saved here.
 * @return If conversion is success, it returns converted data. Otherwise, return nil.
 */
+ (NSData* _Nullable)dataWithXmlNode:(MXEXmlNode* _Nonnull)xmlNode
                         declaration:(NSString* _Nonnull)xmlDeclaration
                               error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert NSData to MXEXmlNode.
 *
 * @param xmlData   An input xml data.
 * @param error     If it return nil, error information is saved here.
 * @return If conversion is success, it returns converted xml node. Otherwise, return nil.
 */
+ (MXEXmlNode* _Nullable)xmlNodeWithData:(NSData* _Nonnull)xmlData
                                   error:(NSError* _Nullable* _Nullable)error;

@end
