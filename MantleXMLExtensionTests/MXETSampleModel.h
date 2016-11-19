//
//  MXETSampleModel.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import "MXEXmlAdapter.h"

@interface MXETSampleModel : MTLModel <MXEXmlSerializing>

@property (nonatomic, nonnull, copy) NSString* a;
@property (nonatomic, nonnull, copy) NSString* b;
@property (nonatomic, nonnull, copy) NSString* c;

@end
