//
//  NSError+MantleXMLExtension.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "NSError+MantleXMLExtension.h"

NSString* _Nonnull const MXEErrorDomain = @"MXEErrorDomain";
NSString* _Nonnull const MXEErrorInputDataKey = @"MXEErrorInputDataKey";

@implementation NSError (MantleXMLExtension)

+ (instancetype _Nonnull)mxe_errorWithMXEErrorCode:(MXEErrorCode)code
{
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : [self mxe_description:code] };
    return [NSError errorWithDomain:MXEErrorDomain code:code userInfo:userInfo];
}

+ (instancetype _Nonnull)mxe_errorWithMXEErrorCode:(MXEErrorCode)code reason:(NSString* _Nonnull)reason
{
    return [self mxe_errorWithMXEErrorCode:code reason:reason additionalInfo:nil];
}

+ (instancetype _Nonnull)mxe_errorWithMXEErrorCode:(MXEErrorCode)code
                                            reason:(NSString* _Nonnull)reason
                                    additionalInfo:(NSDictionary* _Nullable)additionalInfo
{
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : [self mxe_description:code],
                                NSLocalizedFailureReasonErrorKey : reason };
    if (additionalInfo) {
        NSMutableDictionary* mutableUserInfo = [userInfo mutableCopy];
        [mutableUserInfo addEntriesFromDictionary:additionalInfo];
        userInfo = mutableUserInfo;
    }
    return [NSError errorWithDomain:MXEErrorDomain code:code userInfo:userInfo];
}

#pragma mark - Private Method

/**
 * Return a LocalizedDescription.
 *
 * @param code
 * @return description string
 */
+ (NSString* _Nonnull)mxe_description:(MXEErrorCode)code
{
    switch (code) {
        case MXEErrorNil:
            return @"Model doesn't allow nil but nil had be passed";
        case MXEErrorInvalidRootNode:
            return @"Root node has different name from defined in model";
        case MXEErrorInvalidInputData:
            return @"Conversion failed, because input data is invalid";
        default:
            return @"Unknown error";
    }
}

@end
