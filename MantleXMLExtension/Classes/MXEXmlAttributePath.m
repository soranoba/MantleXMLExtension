//
//  MXEXmlAttributePath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlAttributePath+Private.h"

@implementation MXEXmlAttributePath

- (instancetype _Nullable) initWithPaths: (NSArray<NSString*>* _Nonnull)paths
{
    if (self = [super init]) {
        self.paths = paths;
    }
    return self;
}

- (instancetype _Nullable) initWithRootAttribute: (NSString* _Nonnull)attribute
{
    if (self = [super init]) {
        self.paths = @[attribute];
    }
    return self;
}

@end
