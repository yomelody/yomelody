//
//  MyManager.h
//  melody
//
//  Created by coding Brains on 31/08/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import "AudioFeedTableViewCell.h"
#import "ActivitiesTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
@interface MyManager : NSObject {
NSString *someProperty;
}

@property (nonatomic, retain) NSString *someProperty;
@property(nonatomic,strong) AVAudioPlayer *audioPlayer;
-(BOOL)isInternetAvailable;

+ (id)sharedManager;

@end
