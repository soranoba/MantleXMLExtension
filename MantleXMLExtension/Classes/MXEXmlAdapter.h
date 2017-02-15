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
#import "MXEXmlValuePath.h"

extern NSString* _Nonnull const MXEXmlDeclarationDefault;

@protocol MXEXmlSerializing <MTLModel>
@required

/**
 * Specifies how to map property keys to different key paths in XML.
 *
 * When create the following XML model
 *
 *     <?xml version="1.0" encoding="UTF-8"?>
 *     <response>
 *       <status code="200">OK</status>
 *       <total>100</total>
 *       <par_page>2</par_page>
 *       <user><id>1</id></user>
 *       <user><id>2</id></user>
 *     </response>
 *
 * First, specify the XML Root Element name.
 *
 *     + (NSString*) xmlRootElementName
 *     {
 *          return @"response";
 *     }
 *
 * Next, define the correspondence between XML elements and @property.
 *
 *     + (NSDictionary*) xmlKeyPathsByPropertyKey
 *     {
 *         return @{ @"statusCode" : MXEXmlAttribute(@"status", @"code"),
 *                   @"statusValue": @"status"
 *                   @"summary"    : @[@"total", @"par_page"],
 *                   @"userIds"    : MXEArray(@"", @"user.id")}
 *     }
 *
 * The key of dictionary is @property.
 * The value of dictionary support several kinds.
 *
 * @see MXEXmlArrayPath
 * @see MXEXmlAttributePath
 * @see MXEXmlChildNodePath
 * @see MXEXmlValuePath
 *
 * In all cases, use `.` to specify a child element of an element.
 * This is the same format as MTLJSONSerializing.
 *
 * NSString is treated as a syntax suger which generates xml path.
 * (e.g. `@"user.id"` means `MXEXmlValue(@"user.id")`)
 *
 * If you want to associate XML and @property that extracted some elements, use NSArray.
 * In the above example, summary is associated with the following XML.
 *
 *     <?xml version="1.0" encoding="UTF-8"?>
 *     <response>
 *       <total>100</total>
 *       <par_page>2</par_page>
 *     </response>
 *
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
+ (id _Nullable)modelOfClass:(Class _Nonnull)modelClass
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
- (id _Nullable)modelFromXmlData:(NSData* _Nullable)xmlData
                           error:(NSError* _Nullable* _Nullable)error;

/**
 * @see xmlDataFromModel:error:
 */
- (NSData* _Nullable)xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                error:(NSError* _Nullable* _Nullable)error;

@end

@interface MXEXmlAdapter (Transformers)

/**
 * Return a transformer that convert between NSArray<MXEXmlNode> and NSArray<id<MXEXmlSerializing>>.
 *
 * It can use when it specify MXEXmlArray.
 *
 * @param modelClass    A MXEXmlSerializing class
 * @return transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    xmlNodeArrayTransformerWithModelClass:(Class _Nonnull)modelClass;

/**
 * Return a transformer that used when nested child node is a MXEXmlSerializing object.
 *
 * @param modelClass    A MXEXmlSerializing class
 * @return transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    xmlNodeTransformerWithModelClass:(Class _Nonnull)modelClass;

/**
 * Return a transformer that convert between MXEXmlNode and NSDictionary.
 * This transformer create a dictionary with mapping of the keyPath and the valuePath.
 *
 * It specifies a path that will return MXEXmlNode at MXEXmlSerializing # xmlKeyPathsByPropertyKey.
 * For example, it specify MXEXmlChildNodePath or NSArray.
 *
 * @param keyPath      A keyPath that specify target keys of dictionary.
 * @param valuePath    A valuePath that specify target values of dictionary.
 * @return transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    mappingDictionaryTransformerWithKeyPath:(id<MXEXmlAccessible> _Nonnull)keyPath
                                  valuePath:(id<MXEXmlAccessible> _Nonnull)valuePath;

/**
 * Return a transformer that convert between MXEXmlNode and NSDictionary.
 * This transformer create a dictionary from all elements of xml.
 *
 * @see MXEXmlNode # toDictionary
 * @return transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)dictionaryTransformer;

/**
 * Return a transformer that convert between number and string of number.
 *
 * NOTE:
 * It is similar to NSValueTransformer # mtl_numberTransformerWithNumberStype:locale: but there are some differences.
 *
 * When using NSNumberFormatterDecimalStyle it support decimal, but comma will be inserted automatically
 * and the effective number of digits is very small.
 *
 * This transformer resolves those problems.
 *
 * @return transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)numberTransformer;

/**
 * Return a transformer that convert between bool and string of boolean.
 *
 * @return transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)boolTransformer;

@end

@interface MXEXmlAdapter (Deprecated)

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)numberStringTransformer
    __attribute__((unavailable("Replaced by numberTransformer")));

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)boolStringTransformer
    __attribute__((unavailable("Replaced by boolTransformer")));

@end
