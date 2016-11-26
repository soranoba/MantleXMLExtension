//
//  MXETUsersResponse.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import "MXEXmlAdapter.h"

@class MXETError;
@class MXETUser;

/**
 * <?xml version="1.0" encoding="UTF-8"?>
 * <response status="ok">
 *   <summary>
 *     <count>2</count>
 *   </summary>
 *   <user>
 *   </user>
 *   <user>
 *   </user>
 * </response>
 */
@interface MXETUsersResponse : MTLModel <MXEXmlSerializing>

@property (nonatomic, nonnull, strong) NSString* status;
@property (nonatomic, nonnull, strong) NSArray<MXETUser*>* users;
@property (nonatomic, assign) NSInteger userCount;

@end

typedef NS_ENUM(NSUInteger, MXETSex) {
    MXETMan = 1,
    MXETWoman = 2,
};

/**
 * <user first_name="Ai" last_name="Asada">
 *   <age>20</age>
 *   <sex>Woman</sex>
 *   <parent first_name="Ikuo" last_name="Ikeda">
 *     <age>30</age>
 *     <sex>Man</age>
 *   </parent>
 * </user>
 */
@interface MXETUser : MTLModel <MXEXmlSerializing>

@property(nonatomic, nonnull, strong) NSString* firstName;
@property(nonatomic, nonnull, strong) NSString* lastName;
@property(nonatomic, assign) NSInteger age;
@property(nonatomic, assign) MXETSex sex;
@property(nonatomic, nullable, strong) MXETUser* parent;
@property(nonatomic, nullable, strong) MXETUser* child;

@end

/**
 * <?xml version="1.0" encoding="UTF-8"?>
 * <response status="fail">
 *   <error>
 *     <code>404</code>
 *     <description>NOT FOUND</description>
 *   </error>
 * </response>
 */
@interface MXETErrorResponse : MTLModel <MXEXmlSerializing>

@property(nonatomic, nonnull, strong) NSString* status;
@property(nonatomic, nonnull, strong) MXETError* error;

@end

@interface MXETError : MTLModel <MXEXmlSerializing>

@property(nonatomic, assign) NSInteger code;
@property(nonatomic, nonnull, strong) NSString* errorDescription;

@end
