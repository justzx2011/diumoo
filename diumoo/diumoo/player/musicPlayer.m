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
        cond=[[NSCondition alloc] init] ;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ended) name:QTMovieDidEndNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playing_rate) name:QTMovieRateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(load_state:) name:QTMovieLoadStateDidChangeNotification object:nil];
        level=[[FrequencyLevels alloc] init];
        token=YES;
    }
    
    return self;
}

-(void) load_state:(NSNotification*)n
{
    [cond lock];
    //if(![lock tryLock])return;
    if(token) {[cond unlock];return;}
    if([[n.object attributeForKey: QTMovieLoadStateAttribute] intValue]>=QTMovieLoadStatePlayable)
    {
        [level setMovie:n.object];
        [level toggleFreqLevels:NSOnState];
        token=YES;
    }
    [cond unlock];
}

-(void) _start_to_play_notification:(NSDictionary *)m
{
    NSImage* image=[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[m valueForKey:@"Picture"]]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.startToPlay" object:image userInfo:m];
    NSLog(@"before image relase");
    [image release];
    NSLog(@"image release");
}

-(BOOL) startToPlay:(NSDictionary *)music
{
    [cond lock];
    //if(![lock tryLock]) return NO;
    [level toggleFreqLevels: NSOffState];
    if(player!=nil && [player rate]!=0)
    {
        [self _pause];
        NSLog(@"before player released");
        [player invalidate];
        [player release];
        NSLog(@"player released");
    }
    NSError* e=nil;
    NSLog(@"before movie retain");
    player=[[QTMovie movieWithURL:[NSURL URLWithString:[music valueForKey:@"Location"]] error:&e] retain]; 
    NSLog(@"after movie retain");
    token=NO;
    
    if(e==NULL) 
    {
        [self performSelectorInBackground:@selector(_start_to_play_notification:) withObject:music];
        [player autoplay];
    }
    
    [cond unlock];
    return (e==NULL);
}
-(void) _pause
{
    if(player!=nil&&[player rate]!=0){
        [self _set_volume:0];
        [player stop];
    }
}
-(void) play
{
    [cond lock];
   // if(![lock tryLock])return;
    if(player != nil&& [player rate]==0) [player play], [self _set_volume:1.0];
    [cond unlock];
}
-(void) pause
{
    [cond lock];
    //if(![lock tryLock])return;
    [self _pause];
    [cond unlock];
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
    //[cond lock];
    //if(![lock tryLock])return;
    if(player==nil) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.rateChanged" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:[player rate]] forKey:@"rate"] ];
    //[cond unlock];
}


-(void) dealloc
{
    [cond release];
    [player release];
    [super dealloc];
}
@end

