//
//  musicPlayer.h
//  diumoo
//
//  Created by Shanzi on 11-12-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>
#import "FrequencyLevels.h"

#define VOLUME_DURATION 10.0
#define VOLUME_INTERVAL 0.1



@interface musicPlayer : NSObject
{
    QTMovie* player;
    NSCondition* cond;
    FrequencyLevels* level;
    BOOL token;
    
	float autoFadeDuration;
	float autoFadeTargetVolume;
	float autoFadeStartVolume;
	NSTimer* autoFadeTimer;
}

-(void) _start_to_play_notification:(NSDictionary*) m;
-(BOOL) startToPlay:(NSDictionary*) music;

-(void) _pause;
-(void) lazyPause;

-(BOOL) isPlaying;

-(void) play;
-(void) pause;
-(void) ended;
-(void) playing_rate;
- (void)startAutoFadeDuration:(float)duration startVolume:(float)startVolume targetVolume:(float)target;
- (void)stopAutoFade;
- (void)updateAutoFade:(NSTimer*)theTimer;

@end
