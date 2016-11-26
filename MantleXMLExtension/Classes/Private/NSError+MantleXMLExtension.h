//
//  NSError+MantleXMLExtension.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MXEErrorUnknown = 0,
    MXEErrorNil,
    MXEErrorRootNodeInvalid,
    MXEErrorInputDataInvalid,
} MXEErrorCode;

@interface NSError (MantleXMLExtension)

+ (instancetype _Nonnull)errorWithMXEErrorCode:(MXEErrorCode)code;
+ (instancetype _Nonnull)errorWithMXEErrorCode:(MXEErrorCode)code reason:(NSString* _Nonnull)reason;

@end
