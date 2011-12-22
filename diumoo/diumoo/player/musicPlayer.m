//
//  musicPlayer.m
//  diumoo
//
//  Created by Shanzi on 11-12-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "musicPlayer.h"

@implementation musicPlayer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        lock=[[NSLock alloc] init] ;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ended) name:QTMovieDidEndNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playing_rate) name:QTMovieRateDidChangeNotification object:nil];
    }
    
    return self;
}

-(void) _start_to_play_notification:(NSDictionary *)m
{
    NSImage* image=[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[m valueForKey:@"Picture"]]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.startToPlay" object:image userInfo:m];
    [image release];
}

-(BOOL) startToPlay:(NSDictionary *)music
{
    if(![lock tryLock]) return NO;
    if(player!=nil && [player rate]!=0) [self _pause];
    [player invalidate];
    [player release];
    NSError* e=nil;
    //NSLog(@"%@",music);
    player=[[QTMovie movieWithURL:[NSURL URLWithString:[music valueForKey:@"Location"]] error:&e] retain];
    
    [player autoplay];
    [lock unlock];
    if(e==NULL) [self performSelectorInBackground:@selector(_start_to_play_notification:) withObject:music];
    return (e==NULL);
}
-(void) _pause
{
    if(player!=nil&&[player rate]!=0)[self _set_volume:0],[player stop];
}
-(void) play
{
    if(![lock tryLock])return;
    if(player != nil&& [player rate]==0) [player play], [self _set_volume:1.0];
    [lock unlock];
}
-(void) pause
{
    if(![lock tryLock])return;
    [self _pause];
    [lock unlock];
}

-(void) _set_volume:(float)v
{
    if(player ==nil) return;
    float vo=[player volume];
    int i=0;
    for (; i<=VOLUME_DURATION; i++) {
        [player setVolume:(vo+(v-vo) *(i/VOLUME_DURATION))];
       // NSLog(@"%f",[player volume]);
        [NSThread sleepForTimeInterval:VOLUME_INTERVAL];
    }
    
}

-(BOOL) isPlaying
{
    return (player!=nil && [player rate]>0.99);
}



-(void) ended
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.end" object:nil userInfo:nil];
}

-(void) playing_rate
{
    if(![lock tryLock])return;
    if(player==nil) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.rateChanged" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:[player rate]] forKey:@"rate"] ];
    [lock unlock];
}

-(void) dealloc
{
    [lock release];
    [player release];
    [super dealloc];
}
@end
