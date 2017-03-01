//
//  NSError+MantleXMLExtension.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEErrorCode.h"
#import <Foundation/Foundation.h>

#define format(...) ([NSString stringWithFormat:__VA_ARGS__])

@interface NSError (MantleXMLExtension)

/**
 * Create NSError with error code
 *
 * @param code Error code
 * @return instance
 */
+ (instancetype _Nonnull)mxe_errorWithMXEErrorCode:(MXEErrorCode)code;

/**
 * Create NSError with error code and userInfo.
 *
 * @param code        Error code
 * @param userInfo    An userInfo excluding LocalizedDescription. LocalizedDescription will be added automatically.
 * @return instance
 */
+ (instancetype _Nonnull)mxe_errorWithMXEErrorCode:(MXEErrorCode)code
                                          userInfo:(NSDictionary* _Nullable)userInfo;
@end

static inline void setError(NSError* _Nullable* _Nullable error, MXEErrorCode code, NSDictionary* _Nullable userInfo)
{
    if (error) {
        *error = [NSError mxe_errorWithMXEErrorCode:code userInfo:userInfo];
    }
}
