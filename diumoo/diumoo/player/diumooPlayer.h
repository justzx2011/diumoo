//
//  diumooPlayer.h
//  diumoo -- A full function Douban Radio Client
//
//  Created by Shanzi on 11-12-8.
//  Modified by Anakin~Mac(Macidea) on 12-1-22
//
//  Copyright 2011-2012 Macidea.Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>
#import "FrequencyLevels.h"

#define VOLUME_DURATION 10.0f
#define VOLUME_INTERVAL 0.1f


@interface diumooPlayer : NSObject
{
    QTMovie* player;
    NSCondition* condition;
    
    //NSLock* notificationLock;
    
    FrequencyLevels* level;
        
	float autoFadeDuration;
	float autoFadeTargetVolume;
	float autoFadeStartVolume;
	NSTimer* autoFadeTimer;
    NSInteger count;
   // NSDictionary* current_music;
    
    //NSDictionary* songofsnail;
}

//playing functions
-(BOOL) startToPlay:(NSDictionary*) music;
-(void) pause;
-(void) lazyPause;
-(void) resume;
//end of playing functions

-(BOOL) isPlaying;
-(void) ended;
-(void) endedWithError;
-(void) playing_rate;
-(void) loadStateChange:(NSNotification*) n;
//-(void) postMusicNotificationInBackground:(NSDictionary*)music;

//functions that implement Fade in and out
- (void)startAutoFadeDuration:(float)duration startVolume:(float)startVolume targetVolume:(float)target;
- (void)stopAutoFade;
- (void)updateAutoFade:(NSTimer*)theTimer;
//end of functions that implement Fade in and out

@end
