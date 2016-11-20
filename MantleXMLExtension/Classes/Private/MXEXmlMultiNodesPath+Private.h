//
//  MXEXmlMultiNodesPath+Private.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlMultiNodesPath.h"

@interface MXEXmlMultiNodesPath ()
@property(nonatomic, nonnull, copy) NSArray<NSString*>* parentPath;
@property(nonatomic, nonnull, copy) NSArray<NSString*>* pathToBeCollected;
@end
