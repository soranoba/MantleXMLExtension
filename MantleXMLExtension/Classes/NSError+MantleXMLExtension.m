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

@interface NSError (MantleXMLExtension_Private)
/**
 * Return a LocalizedDescription.
 */
+ (NSString* _Nonnull)description:(MXEErrorCode)code;
@end

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

+ (NSString* _Nonnull)description:(MXEErrorCode)code
{
    switch (code) {
        default:
            return @"";
    }
}

@end
