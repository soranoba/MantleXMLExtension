//
//  MXEXmlNode.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MXEXmlNode;
@class MXEMutableXmlNode;

/**
 * A protocol that is possible to get and set value from MXEXmlNode.
 *
 * An instance conforming to this protocol MUST represent XML path.
*/
@protocol MXEXmlAccessible <NSObject>

/**
 * It return an array of element name of node in order from the parent node.
 *
 * @return an array of element name.
 */
- (NSArray<NSString*>* _Nonnull)separatedPath;

/**
 * Get a value from the xmlNode in the path represented by this instance.
 *
 * @param rootXmlNode  The xml node at root.
 * @return The value in the path represented by this instance. If there is no node in path, it returns nil.
 */
- (id _Nullable)getValueFromXmlNode:(MXEXmlNode* _Nonnull)rootXmlNode;

/**
 * Set a value for the xmlNode in the path represented by this instance.
 *
 * @param value        The value to set.
 * @param rootXmlNode  The xml node at root.
 */
- (void)setValue:(id _Nullable)value forXmlNode:(MXEMutableXmlNode* _Nonnull)rootXmlNode;

@end

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
/// It exist only if hasChildren is YES. Either value or children always is nil.
///
/// MXEXmlNode treats it as copy.
/// MXEMutableXMLNode treats it as strong.
@property (nonatomic, nullable, readonly) NSArray<MXEXmlNode*>* children;

/// A value held by this XML node.
///
/// It exist only if hasChildren is NO. Either value or children always is nil.
@property (nonatomic, nullable, copy, readonly) NSString* value;

/// It returns YES, if the MXEXmlNode has children.
/// Otherwise, it returns NO.
@property (nonatomic, assign, readonly) BOOL hasChildren;

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
                                    children:(NSArray<MXEXmlNode*>* _Nullable)children;

/**
 * Create an instance.
 *
 * @param elementName A XML element name.
 * @param attributes  Attribtues held by this XML node.
 * @param value       A value held by this XML node.
 * @return instance
 */
- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
                                  attributes:(NSDictionary<NSString*, NSString*>* _Nullable)attributes
                                       value:(NSString* _Nullable)value;

/**
 * Create an instance from dictionary.
 *
 * @see toDictionary
 *
 * @param elementName A XML element name.
 * @param dictionary  A dictionary that converted all elements of xml.
 * @return instance
 */
- (instancetype _Nonnull)initWithElementName:(NSString* _Nonnull)elementName
                              fromDictionary:(NSDictionary<NSString*, id>* _Nonnull)dictionary;

/**
 * Convert to NSString.
 *
 * @return XmlString. This string does NOT include XML declaration.
 */
- (NSString* _Nonnull)toString;

/**
 * Convert to NSDictionary.
 *
 * - It ignore except for the beginnig child, If there are children with the same name.
 * - It use prefix of `@` for attributes.
 *   For example, it change to `@key` from key, when there exist attribute name is `key`.
 *
 * @return A dictionary that converted all elements of xml.
 */
- (NSDictionary* _Nonnull)toDictionary;

/**
 * It returns whether it is an empty node.
 *
 * @return If it is no attribute and no children, it returns YES. Otherwise, it returns NO.
 */
- (BOOL)isEmpty;

/**
 * Lookup for child that name is elementName and return the found node.
 *
 * @param elementName   Search for node which element name is the elementName.
 * @return It returns a node, if it is found. Otherwise, it returns nil.
 */
- (MXEXmlNode* _Nullable)lookupChild:(NSString* _Nonnull)elementName;

/**
 * Get a value from node specified keypath.
 *
 * @param xmlPath See MXEXmlSerializing # xmlKeyPathsByPropertyKey
 * @return The value type returned by xmlPath is different.
 */
- (id _Nullable)getForXmlPath:(id<MXEXmlAccessible> _Nonnull)xmlPath;

@end

@interface MXEMutableXmlNode : MXEXmlNode

/// @see MXEXmlNode # elementName
@property (nonatomic, nonnull, copy, readwrite) NSString* elementName;
/// @see MXEXmlNode # attributes
@property (nonatomic, nonnull, strong, readwrite) NSMutableDictionary<NSString*, NSString*>* attributes;
/// @see MXEXmlNode # children
@property (nonatomic, nullable, readwrite) NSMutableArray<MXEMutableXmlNode*>* children;
/// @see MXEXmlNode # value
@property (nonatomic, nullable, copy, readwrite) NSString* value;

/**
 * Add the childNode
 *
 * If it have value, it delete the value and set the childNode. 
 * Because, there MUST NOT be exist for both children and value.
 *
 * @param childNode A child to be added.
 */
- (void)addChild:(MXEXmlNode* _Nonnull)childNode;

/**
 * It set to copy all elements from the sourceXmlNode.
 *
 * @param sourceXmlNode  A XmlNode that is source of copy
 */
- (void)setToCopyAllElementsFromXmlNode:(MXEXmlNode* _Nonnull)sourceXmlNode;

/**
 * Set the value to the location specified by keypath.
 *
 * @param value   A value to set. The types supported by xmlPath are different.
 * @param xmlPath See MXEXmlSerializing # xmlKeyPathsByPropertyKey
 */
- (void)setValue:(id _Nullable)value forXmlPath:(id<MXEXmlAccessible> _Nonnull)xmlPath;

@end
