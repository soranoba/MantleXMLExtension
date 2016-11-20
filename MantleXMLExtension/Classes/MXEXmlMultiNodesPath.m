//
//  MXEXmlMultiNodesPath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlMultiNodesPath+Private.h"

@implementation MXEXmlMultiNodesPath

- (instancetype _Nullable) initWithParentPaths: (NSArray<NSString*>* _Nonnull)parentPath
                            pathsToBeCollected: (NSArray<NSString*>* _Nonnull)pathToBeCollected
{
    if (self = [super init]) {
        self.parentPath = parentPath;
        self.pathToBeCollected = pathToBeCollected;
    }
    return self;
}

@end
