//
//  MXEXmlNode.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlPath.h"
#import <Foundation/Foundation.h>

/**
 * Node instance of XML.
 */
@interface MXEXmlNode : NSObject <NSMutableCopying, NSCopying>

/// A XML element name.
@property (nonatomic, nonnull, copy, readonly) NSString* elementName;

/// Attributes held by this XML node.
///
/// MXEXmlNode treats it as copy.
/// MXEMutableXMLNode treats it as strong.
@property (nonatomic, nonnull, readonly) NSDictionary<NSString*, NSString*>* attributes;

/// Children held by this XML node.
///
/// MXEXmlNode treats it as copy.
/// MXEMutableXMLNode treats it as strong.
///
/// Its types supported are NSString or NSArray<MXEXmlNode>
@property (nonatomic, nullable, readonly) id children;

/**
 * @see initWithElementName:attributes:children:
 */
- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName;

/**
 * Create an instance.
 *
 * @param elementName A XML element name.
 * @param attributes  Attributes held by this XML node.
 * @param children    Children held by this XML node.
 * @return instance
 */
- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
                                  attributes:(NSDictionary<NSString*, NSString*>* _Nullable)attributes
                                    children:(id _Nullable)children;
/**
 * Initialize with key path and value.
 *
 * @param xmlPath   NSArray*<NSString*> or NSString*.
 * @param value     Set value the specified path
 * @return instance
 */
- (instancetype _Nullable)initWithXmlPath:(MXEXmlPath* _Nonnull)xmlPath value:(id _Nullable)value;

/**
 * Convert to NSString.
 *
 * @return XmlString. This string does NOT include XML declaration.
 */
- (NSString* _Nonnull)toString;

/**
 * If it is no attribute and no children, it returns YES. Otherwise, it returns NO.
 */
- (BOOL)isEmpty;

/**
 * Lookup for child that name is nodeName and return the found node.
 *
 * @param nodeName Search for nodeName
 * @return Found node
 */
- (MXEXmlNode* _Nullable)lookupChild:(NSString* _Nonnull)nodeName;

/**
 * Get children or attribute from node specified keypath.
 *
 * @param xmlPath See MXEXmlSerializing # xmlKeyPathsByPropertyKey
 * @return NSArray<MXEXmlNode*>* (children) or NSString* (attribute, value)
 */
- (id _Nullable)getForXmlPath:(MXEXmlPath* _Nonnull)xmlPath;

@end

@interface MXEMutableXmlNode : MXEXmlNode

/// @see MXEXmlNode # elementName
@property (nonatomic, nonnull, copy, readwrite) NSString* elementName;
/// @see MXEXmlNode # attributes
@property (nonatomic, nonnull, strong, readwrite) NSMutableDictionary<NSString*, NSString*>* attributes;
/// @see MXEXmlNode # children
@property (nonatomic, nullable, strong, readwrite) id children;

/**
 * Add a child node to the location specified by keypath.
 *
 * @param value   KeyPath's node has this string.
 * @param xmlPath See MXEXmlSerializing # xmlKeyPathsByPropertyKey
 */
- (BOOL)setValue:(id _Nullable)value forXmlPath:(MXEXmlPath* _Nonnull)xmlPath;

@end
