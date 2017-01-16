//
//  MXEXmlAdapter.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLTransformerErrorHandling.h>

#import "MXEErrorCode.h"
#import "MXEXmlArrayPath.h"
#import "MXEXmlAttributePath.h"
#import "MXEXmlChildNodePath.h"

extern NSString* _Nonnull const MXEXmlDeclarationDefault;

@protocol MXEXmlSerializing <MTLModel>
@required

/**
 * Specifies how to map property keys to different key paths in XML.
 *
 * <?xml version="1.0" encoding="UTF-8"?>
 * <response>
 *   <status code="200" value="OK" />
 *   <summary>
 *      <total>2</total>
 *   </summary>
 *   <user><id>1</id></user>
 *   <user><id>2</id></user>
 * </response>
 *
 * --- 1st case is...
 *
 * + (NSString*) xmlRootElementName { return @"response"; }
 * + (NSDictionary*) xmlKeyPathsByPropertyKey
 * {
 *     return @{ @"statusCode" : MXEXmlAttribute(@"status", @"code"),
 *               @"statusValue": MXEXmlAttribute(@"status", @"value"),
 *               @"totalCount" : @"summary.total",
 *               @"userIds"    : MXEArray(@".", @"user.id")}
 * }
 *
 * --- 2nd case: Replace user to MXEXmlSerializing model class in 1st case.
 *
 * + (NSDictionary*) xmlKeyPathsByPropertyKey
 * {
 *     return @{ @"statusCode" : MXEXmlAttribute(@"status", @"code"),
 *               @"statusValue": MXEXmlAttribute(@"status", @"value"),
 *               @"totalCount" : @"summary.total",
 *               @"userIds"    : MXEArray(@".", @"user")}
 * }
 *
 * User model
 * + (NSString*) xmlRootElementName { return @"user"; }
 * + (NSDictionary*) xmlKeyPathsByPropertyKey
 * {
 *     return @{ @"userId" : @"id" }
 * }
 */
+ (NSDictionary<NSString*, id>* _Nonnull)xmlKeyPathsByPropertyKey;

/**
 * Return a element name of XML root node.
 *
 * @see xmlKeyPathsByPropertyKey
 */
+ (NSString* _Nonnull)xmlRootElementName;

@optional

/**
 * Specifies how to convert a Xml value to the given property key.
 *
 * If the receiver implements a `+<key>XmlTransformer` method,
 * MXEXmlAdapter will use the result of that method instead.
 */
+ (NSValueTransformer* _Nullable)xmlTransformerForKey:(NSString* _Nonnull)key;

/**
 * Specifies the order of child nodes.
 * Those not included in returned list are arranged randomly (in the order in which NSDictionary returns).
 * After that, arrange them in order from the beginning included in the list.
 */
+ (NSArray* _Nonnull)xmlChildNodeOrder;

/**
 * Return a XML declaration. It use when model convert to XML.
 *
 * default: MXEXmlDeclarationDefault
 */
+ (NSString* _Nonnull)xmlDeclaration;
@end

@interface MXEXmlAdapter : NSObject

#pragma mark - Lifecycle

/**
 * Create a adapter
 *
 * @param modelClass MXEXmlSerializing model class
 * @return instance
 */
- (instancetype _Nullable)initWithModelClass:(Class _Nonnull)modelClass;

#pragma mark - Conversion between XML and Model

/**
 * Convert xml to model
 *
 * @param modelClass MXEXmlSerializing model class
 * @param xmlData    XML data
 * @param error      If it return nil, error information is saved here.
 * @return If conversion is success, return model object. Otherwise, return nil.
 */
+ (id<MXEXmlSerializing> _Nullable)modelOfClass:(Class _Nonnull)modelClass
                                    fromXmlData:(NSData* _Nullable)xmlData
                                          error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert model to xml
 *
 * @param model MXEXmlSerializing model object
 * @param error If it return nil, error information is saved here.
 * @return If conversion is success, return xml data. Otherwise, return nil.
 */
+ (NSData* _Nullable)xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                error:(NSError* _Nullable* _Nullable)error;

/**
 * @see modelOfClass:fromXmlData:error:
 */
- (id<MXEXmlSerializing> _Nullable)modelFromXmlData:(NSData* _Nullable)xmlData
                                              error:(NSError* _Nullable* _Nullable)error;

/**
 * @see xmlDataFromModel:error:
 */
- (NSData* _Nullable)xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                error:(NSError* _Nullable* _Nullable)error;

#pragma mark - Transformer

/**
 * Return the transformer that specify when use MXEXmlArray.
 *
 * @return transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    xmlNodeArrayTransformerWithModelClass:(Class _Nonnull)modelClass;

/**
 * Return the transformer that used when nested child node is a MXEXmlSerializing object.
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    xmlNodeTransformerWithModelClass:(Class _Nonnull)modelClass;

@end
