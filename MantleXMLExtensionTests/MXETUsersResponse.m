//
//  MXETUsersResponse.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXETUsersResponse.h"

@implementation MXETUsersResponse

+ (NSDictionary<NSString*, id>* _Nonnull) xmlKeyPathsByPropertyKey {
    return @{@"status":MXEXmlAttribute(@"", @"status"),
             @"users" :MXEXmlDuplicateNodes(@"", @"user")};
}

+ (NSString* _Nonnull) xmlRootElementName {
    return @"response";
}

@end

@implementation MXETUser

+ (NSDictionary<NSString*, id>* _Nonnull) xmlKeyPathsByPropertyKey {
    return @{@"firstName":MXEXmlAttribute(@"", @"first_name"),
             @"lastName" :MXEXmlAttribute(@"", @"last_name"),
             @"age"      :@"age",
             @"sex"      :@"sex"};
}

+ (NSString* _Nonnull) xmlRootElementName {
    return @"user";
}

@end
