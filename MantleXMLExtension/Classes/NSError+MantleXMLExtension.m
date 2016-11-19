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

+ (instancetype _Nonnull) errorWithMXEErrorCode:(MXEErrorCode)code
{
    return [self errorWithMXEErrorCode:code reason:[self defaultReason:code]];
}

+ (instancetype _Nonnull) errorWithMXEErrorCode:(MXEErrorCode)code reason:(NSString* _Nonnull)reason
{
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey: reason};
    return [NSError errorWithDomain:MXEErrorDomain code:code userInfo:userInfo];
}

#pragma mark - Private Method

+ (NSString* _Nonnull) defaultReason:(MXEErrorCode)code
{
    switch (code) {
        default:
            return @"";
    }
}

@end
