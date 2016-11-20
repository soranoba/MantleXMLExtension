//
//  MXEXmlDuplicateNodesPath.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/20.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlDuplicateNodesPath+Private.h"

@implementation MXEXmlDuplicateNodesPath

- (instancetype _Nullable) initWithParentNodePath: (NSString* _Nullable)parentNodePath
                              collectRelativePath: (NSString* _Nonnull)collectRelativePath
{
    NSParameterAssert(collectRelativePath != nil && collectRelativePath.length > 0);

    if (self = [super init]) {
        self.parentNodePath = parentNodePath;
        self.collectRelativePath = collectRelativePath;
    }
    return self;
}

+ (instancetype _Nullable) pathWithParentNode: (NSString* _Nullable)parentNodePath
                              collectRelative: (NSString* _Nonnull)collectRelativePath
{
    return [[self alloc] initWithParentNodePath:parentNodePath
                            collectRelativePath:collectRelativePath];
}

@end
