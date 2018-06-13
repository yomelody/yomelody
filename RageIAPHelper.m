//
//  RageIAPHelper.m
//  In App Purchase Test
//
//  Created by Swapnil Godambe on 16/02/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "RageIAPHelper.h"

@implementation RageIAPHelper

+ (RageIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static RageIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
//                                      @"com.Yomelody.1.FreePack",
                                      @"com.Yomelody.2.Standard_Pack",
                                      @"com.Yomelody.3.Premium_Pack",//com.Yomelody.3.Premium
                                      @"com.Yomelody.4.Producer_Pack",//com.Yomelody.1.Freemium
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
