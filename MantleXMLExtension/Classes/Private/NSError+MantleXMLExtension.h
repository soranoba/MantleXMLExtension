//
//  NSError+MantleXMLExtension.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEErrorCode.h"
#import <Foundation/Foundation.h>

@interface NSError (MantleXMLExtension)

/**
 * Create NSError with error code
 *
 * @param code Error code
 * @return instance
 */
+ (instancetype _Nonnull)mxe_errorWithMXEErrorCode:(MXEErrorCode)code;

/**
 * Create NSError with error code and reason
 *
 * @param code   Error code
 * @param reason Error reason
 * @return instance
 */
+ (instancetype _Nonnull)mxe_errorWithMXEErrorCode:(MXEErrorCode)code reason:(NSString* _Nonnull)reason;

/**
 * Create NSError with error code and reason, additional informations.
 *
 * @param code            Error code
 * @param reason          Error reason
 * @param additionalInfo  Additional informations to include in userInfo.
 * @return instance
 */
+ (instancetype _Nonnull)mxe_errorWithMXEErrorCode:(MXEErrorCode)code
                                            reason:(NSString* _Nonnull)reason
                                    additionalInfo:(NSDictionary* _Nullable)additionalInfo;
@end

static inline void setError(NSError* _Nullable* _Nullable error, MXEErrorCode code, NSString* _Nullable reason,
                            NSDictionary* _Nullable additionalInfo)
{
    if (error) {
        if (reason) {
            *error = [NSError mxe_errorWithMXEErrorCode:code reason:reason additionalInfo:additionalInfo];
        } else {
            *error = [NSError mxe_errorWithMXEErrorCode:code];
        }
    }
}
