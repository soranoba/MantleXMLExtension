//
//  MXEXmlNode.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXEXmlNode : NSObject

@property (nonatomic, nonnull, copy) NSString* elementName;
@property (nonatomic, nullable, copy) NSDictionary<NSString*, NSString*>* attributes;
/// NSString* or NSArray<MXEXmlNode*>*
/// It MUST set strong. Because, parser insert a NSMutableArray and edit later.
/// Therefore, it SHOULD NOT be used as a public instance.
@property (nonatomic, nullable, strong) id children;

/**
 * Initialize with element name.
 * @param elementName XML element name
 * @return instance
 */
- (instancetype _Nullable)initWithElementName:(NSString* _Nonnull)elementName;

/**
 * Convert to NSString.
 * @return XmlString
 */
- (NSString* _Nonnull)toString;

@end
