//
//  MXEXmlAdapter.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import "MXEXmlAttributePath.h"

static NSString* _Nonnull const MXEXmlDeclarationDefault = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";

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
 * This case is...
 *
 * + (NSString*) xmlRootElementName { return @"response"; }
 * + (NSDictionary*) xmlKeyPathsByPropertyKey
 * {
 *     return @{ @"statusCode" : [[MXEXmlAttributePath alloc] initWithPaths:@[@"status", @"code"]],
 *               @"statusValue": [[MXEXmlAttributePath alloc] initWithPaths:@[@"status", @"value"]],
 *               @"totalCount" : @[@"summary", @"total"],
 *               @"userIds"    : [[MXEXmlMultiNodesPath alloc] initWithParentPaths:@[]
 *                                                              pathsToBeCollected:@[@"user", @"id"]]}
 * }
 */
+ (NSDictionary<NSString*, id>* _Nonnull) xmlKeyPathsByPropertyKey;

/**
 * Return a element name of XML root node.
 *
 * @see +xmlKeyPathsByPropertyKey
 */
+ (NSString* _Nonnull) xmlRootElementName;

@optional

/**
 * Specifies how to convert a Xml value to the given property key.
 *
 * If the receiver implements a `+<key>XmlTransformer` method, MXEXmlAdapter
 * will use the result of that method instead.
 *
 */
+ (NSValueTransformer* _Nullable)xmlTransformerForKey:(NSString* _Nonnull)key;

/**
 * Return a XML declaration. It use when model convert to XML.
 *
 * default: MXEXmlDeclarationDefault
 */
+ (NSString* _Nonnull)xmlDeclaration;
@end

@interface MXEXmlAdapter : NSObject

#pragma mark - Life cycle

- (instancetype _Nullable) initWithModelClass:(Class<MXEXmlSerializing> _Nonnull)modelClass;

#pragma mark - Conversion between XML and Model

+ (id<MXEXmlSerializing> _Nullable) modelOfClass:(Class<MXEXmlSerializing> _Nonnull)modelClass
                                     fromXmlData:(NSData* _Nullable)XmlData
                                           error:(NSError* _Nullable * _Nullable)error;

+ (NSData* _Nullable) xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                 error:(NSError* _Nullable * _Nullable)error;

- (id<MXEXmlSerializing> _Nullable) modelFromXmlData:(NSData* _Nullable)xmlData
                                               error:(NSError* _Nullable * _Nullable)error;

- (NSData* _Nullable) xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                 error:(NSError* _Nullable * _Nullable)error;

@end
