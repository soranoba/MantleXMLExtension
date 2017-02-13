//
//  MXEErrorCode.h
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/01/17.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MXEErrorCode) {
    MXEErrorUnknown = 0,
    MXEErrorNil,
    MXEErrorInvalidRootNode,
    MXEErrorInvalidInputData,
};

/// The domain for errors originating from MantleXMLExtension
extern NSString* _Nonnull const MXEErrorDomain;
