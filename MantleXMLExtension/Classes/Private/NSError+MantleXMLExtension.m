//
//  NSError+MantleXMLExtension.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "NSError+MantleXMLExtension.h"

/// The domain for errors originating from MantleXMLExtension
static NSString* const MXEErrorDomain = @"MXEErrorDomain";

@implementation NSError (MantleXMLExtension)

+ (instancetype _Nonnull)errorWithMXEErrorCode:(MXEErrorCode)code
{
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : [self description:code] };
    return [NSError errorWithDomain:MXEErrorDomain code:code userInfo:userInfo];
}

+ (instancetype _Nonnull)errorWithMXEErrorCode:(MXEErrorCode)code reason:(NSString* _Nonnull)reason
{
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : [self description:code],
                                NSLocalizedFailureReasonErrorKey : reason };
    return [NSError errorWithDomain:MXEErrorDomain code:code userInfo:userInfo];
}

#pragma mark - Private Method

/**
 * Return a LocalizedDescription.
 *
 * @param code
 * @return description string
 */
+ (NSString* _Nonnull)description:(MXEErrorCode)code
{
    switch (code) {
        case MXEErrorNil:
            return @"Model doesn't allow nil but nil had be passed";
        case MXEErrorInvalidRootNode:
            return @"Root node has different name from defined in model";
        case MXEErrorInvalidInputData:
            return @"Input data is invalid";
        default:
            return @"Unknown error";
    }
}

@end
