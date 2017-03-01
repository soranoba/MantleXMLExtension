//
//  MXEXmlChildNodePathTests.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/27.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlChildNodePath.h"
#import "MXEXmlNode.h"

QuickSpecBegin(MXEXmlChildNodePathTests)
{
    describe(@"description", ^{
        it(@"is correct description", ^{
            MXEXmlChildNodePath* path = MXEXmlChildNode(@"a.b");
            expect([path description]).to(equal(@"MXEXmlChildNode(@\"a.b\")"));
        });
    });
}
QuickSpecEnd
