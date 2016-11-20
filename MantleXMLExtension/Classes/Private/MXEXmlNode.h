//
//  MXEXmlNode.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXEXmlAttributePath+Private.h"
#import "MXEXmlDuplicateNodesPath+Private.h"

@class MXEXmlNode;
typedef void(^MXEXmlNodeInsertBlock)(MXEXmlNode* _Nonnull);

@interface MXEXmlNode : NSObject

@property (nonatomic, nonnull, copy) NSString* elementName;

/// It MUST set strong. Because, MXEXmlNode insert a NSMutableDictionary and edit later.
/// Therefore, it SHOULD NOT be used as a public instance.
@property (nonatomic, nullable, strong) NSDictionary<NSString*, NSString*>* attributes;

/// NSString* or NSArray<MXEXmlNode*>*
/// It MUST set strong. Because, parser insert a NSMutableArray and edit later.
/// Therefore, it SHOULD NOT be used as a public instance.
@property (nonatomic, nullable, strong) id children;

/**
 * Initialize with element name.
 * @param elementName XML element name
 * @return instance
 */
- (instancetype _Nullable) initWithElementName:(NSString* _Nonnull)elementName;

/**
 * Initialize with key path.
 *
 * @param keyPath   NSArray*<NSString*> or NSString*.
 * @return instance
 */
- (instancetype _Nullable) initWithKeyPath:(id _Nonnull)keyPath;

/**
 * Initialize with key path and value.
 *
 * @param keyPath   NSArray*<NSString*> or NSString*.
 * @param value     Set value the most child level node.
 * @return instance
 */
- (instancetype _Nullable) initWithKeyPath:(id _Nonnull)keyPath value:(NSString* _Nullable)value;


- (instancetype _Nullable) initWithKeyPath:(id _Nonnull)keyPath
                                    blocks:(MXEXmlNodeInsertBlock _Nullable)blocks;

/**
 * Convert to NSString.
 *
 * @return XmlString. This string does NOT include XML declaration.
 */
- (NSString* _Nonnull) toString;

/**
 * Get children or attribute from node specified keypath.
 *
 * @param keyPath See MXEXmlSerializing +xmlKeyPathsByPropertyKey
 * @return NSArray<MXEXmlNode*>* (children) or NSString* (attribute, value)
 */
- (id _Nullable)getChildForKeyPath:(id _Nonnull)keyPath;

/**
 * Add a child node to the location specified by keypath.
 *
 * @param value   KeyPath's node has this string.
 * @param keyPath See MXEXmlSerializing +xmlKeyPathsByPropertyKey
 */
- (void) setChild:(NSString* _Nonnull)value forKeyPath:(id _Nonnull)keyPath;

/**
 * Add a child node to the location specified by keypath.
 *
 * @param blocks  When keyPath's node insert, this block is called. Input param is keyPath's node.
 * @param keyPath See MXEXmlSerializing +xmlKeyPathsByPropertyKey
 */
- (void) setChildWithBlocks:(MXEXmlNodeInsertBlock _Nonnull)blocks forKeyPath:(id _Nonnull)keyPath;

@end
