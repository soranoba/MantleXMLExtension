//
//  MXEXmlPath.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/23.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXEXmlPath : NSObject

- (instancetype _Nonnull)initWithNodePath:(id _Nonnull)nodePath;

+ (instancetype _Nonnull)pathWithNodePath:(id _Nonnull)nodePath;

@end
