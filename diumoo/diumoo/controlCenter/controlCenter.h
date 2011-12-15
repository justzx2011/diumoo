//
//  musicController.h
//  diumoo
//
//  Created by Shanzi on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mediaSourceBase.h"
#import "musicPlayer.h"

#define ENDED @"ended"
#define RATE_CHANGED @"ratechanged"
#define START_TO_PLAY @"starttoplay"

#define PLAYER_STATE_READY (1)
#define SOURCE_STATE_READY (1<<1)

@interface controlCenter : NSObject
{
    musicPlayer* player;
    mediaSourceBase* source;
    NSDictionary* current;
    NSLock* lock;
    NSInteger state;
}

+(controlCenter*) sharedControlCenter;

+(void) postNotificationInBackgroudWithTypeName:(NSString*) s andUserInfo:(NSDictionary*)info;

+(void)music:(NSDictionary*) music playingEndedNotificationFromPlayer:(musicPlayer*) player;
+(void)music:(NSDictionary*) music startToPlayNotificationFromPlayer:(musicPlayer*) player withImage:(NSImage*)image;
+(void)music:(NSDictionary*) music playingRateChangedNotificationFromPlayer:(musicPlayer*) player;

+(void)sendPlayControlSignal;
+(void)sendPauseControlSignal;
+(void)sendPlayOrPauseControlSignal;
+(void)sendLikeControlSignal;
+(void)sendUnlikeControlSignal;
+(void)sendByeControlSignal;
+(void)sendSkipControlSignal;

+(void) addObserver:(id) obj;
+(void) addObserver:(id) obj forNotificationNames:(NSArray*) list; 

-(void) musicEnded;

-(BOOL) setPlayer:(musicPlayer*) player;
-(BOOL) setSource:(mediaSourceBase*) source;
-(id) getPlayer;
-(id) getSource;


-(BOOL) _start_to_play;
-(BOOL) play_pause;
-(BOOL) play;
-(BOOL) pause;
-(BOOL) skip;
-(BOOL) rate;
-(BOOL) unrate;
-(BOOL) bye;
-(BOOL) changeChannelTo:(NSInteger) channel;

@end
