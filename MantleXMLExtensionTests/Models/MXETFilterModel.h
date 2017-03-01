//
//  MXETFilterModel.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/08.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlAdapter.h"
#import <Foundation/Foundation.h>

@class MXETFilterChildModel;

@interface MXETFilterModel : MTLModel <MXEXmlSerializing>
@property (nonatomic, nullable, strong) MXETFilterChildModel* node;
@end

@interface MXETFilterChildModel : MTLModel <MXEXmlSerializing>
@property (nonatomic, nullable, copy) NSString* attribute;
@property (nonatomic, nullable, copy) NSString* userName;
@end
