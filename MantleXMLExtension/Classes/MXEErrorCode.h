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
    /// Could not conversion, because nil was inputted.
    MXEErrorNilInputData,
    /// The element name of the XML Node is different from defined one in the model class
    MXEErrorElementNameDoesNotMatch,
    /// There was an input data that is different from the expected type.
    MXEErrorInvalidInputData,
};

/// The domain for errors originating from MantleXMLExtension
extern NSString* _Nonnull const MXEErrorDomain;
/// A key that stores the input data that caused the error
extern NSString* _Nonnull const MXEErrorInputDataKey;
