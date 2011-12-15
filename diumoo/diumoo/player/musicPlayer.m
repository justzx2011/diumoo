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
        condition=[[[NSCondition alloc] init] retain];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ended) name:QTMovieDidEndNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playing_rate) name:QTMovieRateDidChangeNotification object:nil];
    }
    
    return self;
}

-(BOOL) startToPlay:(NSDictionary *)music
{
    [condition lock];
    if(player!=nil && [player rate]!=0) [self _pause]; 
    [player release];
    NSImage*image=[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[music valueForKey:@"Picture"]]];
    if(image==nil) return NO;
    NSError* e=nil;
    NSLog(@"%@",music);
    player=[[QTMovie movieWithURL:[NSURL URLWithString:[music valueForKey:@"Location"]] error:&e] retain];
    if(e==NULL)[controlCenter music:music startToPlayNotificationFromPlayer:self withImage:image] ;
    [condition unlock],[player autoplay];;
    return (e==NULL);
}
-(void) _pause
{
    if(player!=nil&&[player rate]!=0)[self _set_volume:0],[player stop];
}
-(void) play
{
    [condition lock];
    if(player != nil&& [player rate]==0) [player play], [self _set_volume:1.0];
    [condition unlock];
}
-(void) pause
{
    [condition lock];
    [self _pause];
    [condition unlock];
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


-(void) dealloc
{
    [condition release];
    [player release];
    [super dealloc];
}

-(void) ended
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.end" object:nil userInfo:nil];
}

-(void) playing_rate
{
    [condition lock];
    if(player==nil) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.rateChanged" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:[player rate]] forKey:@"rate"] ];
    [condition unlock];
}

@end
