//
//  NSError+MantleXMLExtension.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MXEErrorCode) {
    MXEErrorUnknown = 0,
    MXEErrorNil,
    MXEErrorInvalidRootNode,
    MXEErrorInvalidInputData,
};

@interface NSError (MantleXMLExtension)

/**
 * Create NSError with error code
 *
 * @param code Error code
 * @return instance
 */
+ (instancetype _Nonnull)errorWithMXEErrorCode:(MXEErrorCode)code;

/**
 * Create NSError with error code and reason
 *
 * @param code   Error code
 * @param reason Error reason
 * @return instance
 */
+ (instancetype _Nonnull)errorWithMXEErrorCode:(MXEErrorCode)code reason:(NSString* _Nonnull)reason;

@end
