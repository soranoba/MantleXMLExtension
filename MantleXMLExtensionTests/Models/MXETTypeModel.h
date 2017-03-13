//
//  MXETTypeModel.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/12/05.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlAdapter.h"
#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>

@interface MXETTypeModel : MTLModel <MXEXmlSerializing>

@property (nonatomic, assign) NSInteger intNum;
@property (nonatomic, assign) NSUInteger uintNum;
@property (nonatomic, assign) double doubleNum;
@property (nonatomic, assign) float floatNum;
@property (nonatomic, assign) BOOL boolNum;

@end
