//
//  MyManager.m
//  melody
//
//  Created by coding Brains on 31/08/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import "MyManager.h"
#import "Constant.h"

@implementation MyManager
{
    long instrument_play_index;
}
@synthesize someProperty;
#pragma mark Singleton Methods

+ (id)sharedManager {
    static MyManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        someProperty = @"Default Property Value";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


-(void)playAudio:(NSString *)strUrl index:(int)index{
    
                        [SVProgressHUD dismiss];
                        [self.audioPlayer stop];
                        [self.audioPlayer play];
                        
    
}

-(BOOL)isInternetAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
