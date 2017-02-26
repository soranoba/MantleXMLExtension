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

+ (instancetype _Nonnull)mxe_errorWithMXEErrorCode:(MXEErrorCode)code
                                          userInfo:(NSDictionary* _Nullable)userInfo
{
    if (userInfo) {
        NSMutableDictionary* mutableUserInfo = [userInfo mutableCopy];
        mutableUserInfo[NSLocalizedDescriptionKey] = [self mxe_description:code];
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
        case MXEErrorNilInputData:
            return @"Could not conversion, because nil was inputted";
        case MXEErrorElementNameDoesNotMatch:
            return @"The element name of the XML Node is different from defined one in the model class";
        case MXEErrorInvalidInputData:
            return @"Transformation failed, because input data is invalid";
        case MXEErrorInvalidXmlDeclaration:
            return @"Input a xml declaration is invalid format";
        case MXEErrorNotSupportedEncoding:
            return @"MantleXMLExtension does not support the encoding";
        case MXEErrorNoConversionTarget:
            return @"There is no target to convert";
        default:
            return @"Unknown error";
    }
}

@end
