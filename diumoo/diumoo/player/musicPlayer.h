//
//  musicPlayer.h
//  diumoo
//
//  Created by Shanzi on 11-12-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

#define VOLUME_DURATION 10.0
#define VOLUME_INTERVAL 0.1

@interface musicPlayer : NSObject
{
    QTMovie* player;
    NSCondition* condition;
}

-(void) _start_to_play_notification:(NSDictionary*) m;
-(BOOL) startToPlay:(NSDictionary*) music;

-(void) _pause;
-(void) _set_volume:(float) v;

-(BOOL) isPlaying;

-(void) play;
-(void) pause;
-(void) ended;
-(void) playing_rate;

@end
