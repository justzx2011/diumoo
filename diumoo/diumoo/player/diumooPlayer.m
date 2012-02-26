//
//  diumooPlayer.m
//  diumoo -- A full function Douban Radio Client
//
//  Created by Shanzi on 11-12-8.
//  Modified by Anakin~Mac(Macidea) on 12-1-22
//
//  Copyright 2011-2012 Macidea.Team. All rights reserved.
//

#import "diumooPlayer.h"


@implementation diumooPlayer

//----------------------------------------- init and dealloc-----------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        count=0;
        //--------------------------------- register notification observer --------------------------
        
        [[NSNotificationCenter defaultCenter]addObserver:self 
                                                selector:@selector(playing_rate) 
                                                    name:QTMovieRateDidChangeNotification 
                                                  object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self 
                                                selector:@selector(loadStateChange:) 
                                                    name:QTMovieLoadStateDidChangeNotification 
                                                  object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self 
                                                selector:@selector(stopAutoFade) 
                                                    name:@"playbuttonpressed" 
                                                  object:nil];
        
        //---------------------------------@ register notification observer -------------------------
        condition=[[NSCondition alloc] init];
       // notificationLock=[[NSLock alloc] init];
        
        level=[[FrequencyLevels alloc] init];
        //init song of snail
    }
    
    return self;
}

//-(void) postMusicNotificationInBackground:(NSDictionary *)music
//{
//    if(![notificationLock tryLock]) return;
//    bool issnail=[[music valueForKey:@"issnail"] boolValue];
//    NSImage* image=nil;
//    if(issnail) 
//        image=[NSImage imageNamed:@"songofsnail.png"];
//    else 
//    {
//        image=[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[music valueForKey:@"Picture"]]];
//        [image autorelease];       
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.startToPlay" object:image userInfo:music];
//    if(!issnail){
//        [current_music release];
//         current_music=nil;
//    }
//    [notificationLock unlock];
//}

-(void)loadStateChange:(NSNotification *)n
{
    NSLog(@"STATE: %@",[player attributeForKey:QTMovieLoadStateAttribute] );
    if([[player attributeForKey:QTMovieLoadStateAttribute] longValue]<0){
        NSLog(@"LoadError");
        if((++count)>5){
            //[self performSelectorInBackground:@selector(postMusicNotificationInBackground:) withObject:songofsnail];
            //[NSThread sleepForTimeInterval:0.2];
           // NSRunCriticalAlertPanel(NSLocalizedString(@"ERORR", nil), NSLocalizedString(@"GET_NEW_SONG_FAILED", nil), NSLocalizedString(@"KNOWN", nil), nil, nil);
        }
        else{[self endedWithError];}
        return;
    }
 // [self performSelectorInBackground:@selector(postMusicNotificationInBackground:) withObject:current_music];
    else count=0;
}

-(void) dealloc
{
    
    [condition release];
    [player release];
    [level release];
    [super dealloc];
}

//-----------------------------------------@ init and dealloc----------------------------------------


//----------------------------------------- playing functions ---------------------------------------

-(BOOL) startToPlay:(NSDictionary *)music
{
    //--------------------------make sure player is on the main thread-------------------------------
    
    
    
    if(![NSThread isMainThread])
    {
        [self lazyPause];
        [self performSelectorOnMainThread:@selector(startToPlay:) withObject:music waitUntilDone:YES];
        return YES;
    }
    
    if (autoFadeTimer != nil) 
    {
		[self stopAutoFade];
	}
    
    
    [condition lock];
    [level toggleFreqLevels:NSOffState];
    if(player){
        [player invalidate];
        [player release];
        player=nil;
    }
    
    NSError* error = nil;
    player=[[QTMovie movieWithURL:[NSURL URLWithString:[music valueForKey:@"Location"]] error:&error] retain]; 

    if(error==NULL) 
    {
        
        [player autoplay];
        [player setVolume:1.0];
        
        NSImage* image=[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[music valueForKey:@"Picture"]]];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"player.startToPlay" object:image userInfo:music];
        
        [image release];
    }
    else [self endedWithError];
    
    [condition unlock];
    return (error==NULL);
}

-(void) pause
{
    [condition lock];
    if(player!=nil&&[player rate]!=0)
    {
        [self startAutoFadeDuration:VOLUME_INTERVAL startVolume:1.0f targetVolume:0.0f];
    }
    [condition unlock];
}

-(void) resume
{
    [condition lock];
    if(player != nil)
    {
        [player play];
        [self startAutoFadeDuration:0.5f startVolume:0.0f targetVolume:1.0f];
    }
    [condition unlock];
}

-(void) lazyPause
{
    [condition lock];
    if(player ==nil || [player rate]<0.1){
        [condition unlock];
        return;
    }
        
    float v=0.0f;
    float vo=[player volume];
    int i=0;
    for (; i<=VOLUME_DURATION; i++) {
        [player setVolume:(vo+(v-vo) *(i/VOLUME_DURATION))];
        [NSThread sleepForTimeInterval:VOLUME_INTERVAL];
    }
    [player stop];
    [condition unlock];
}

//-----------------------------------------@ playing functions------------------------------------------

//--------------------------------- Auto Fade In and Out functions--------------------------------------

- (void)startAutoFadeDuration:(float)duration startVolume:(float)startVolume targetVolume:(float)target 
{
	if (autoFadeTimer != nil) {
		[self stopAutoFade];
	}
    if(target<0.1f && [player rate]<0.1f) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.rateChanged" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:target] forKey:@"rate"] ];
	autoFadeDuration = duration;
	autoFadeStartVolume = startVolume;
	autoFadeTargetVolume = target;
    autoFadeTimer = [[NSTimer timerWithTimeInterval:duration target:self selector:@selector(updateAutoFade:) userInfo:nil repeats:YES]retain];
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), (CFRunLoopTimerRef)autoFadeTimer, kCFRunLoopCommonModes);
	[autoFadeTimer fire];
}

- (void)stopAutoFade {
	if (autoFadeTimer != nil) {
		[autoFadeTimer invalidate];
		[autoFadeTimer release];
		autoFadeTimer = nil;
        if (autoFadeTargetVolume==0) {
            [player stop];
        }
	}
}

- (void)updateAutoFade:(NSTimer*)theTimer
{
    if (autoFadeTargetVolume==0)
    {
        if (player.volume>0) 
        {
            [player setVolume:([player volume]-(1/VOLUME_DURATION))];
            //NSLog(@"Volume(>0) = %lf",[player volume]);
        } 
        else [self stopAutoFade];
    }
    else
    {
        if (autoFadeTargetVolume == 1 && [player volume] < 1) 
        {
            [player setVolume:([player volume]+(1/VOLUME_DURATION))];
            //NSLog(@"Volume(<1) = %lf",[player volume]);
        } else 
        {
            [self stopAutoFade];
        }
    }
}
//---------------------------------@ Auto Fade In and Out functions-------------------------------------


-(BOOL) isPlaying
{
    BOOL isPlaying = (player!=nil && [player rate]>0.9);
    return isPlaying;
}

-(void) ended
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.end" object:nil userInfo:nil];
}
-(void) endedWithError
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.end" object:self userInfo:nil];
}

-(void) playing_rate
{
    if(player==nil) 
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.rateChanged" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:[player rate]] forKey:@"rate"] ];
    
    #ifdef DEBUG
        NSLog(@"Playing %lld/%lld",[player currentTime].timeValue,[player duration].timeValue);
    #endif
    
    if([player rate]>0.95f)
    {
        [level toggleFreqLevels:NSOffState];
        [level setMovie:player];
        [level toggleFreqLevels:NSOnState];
    }
    
    else
    {
        [level toggleFreqLevels:NSOffState];
        [level setMovie:nil];
        
        if(([player duration].timeValue - [player currentTime].timeValue)<100) 
            [self ended];
        if([player rate]>0.01f) [player setRate:1.0f];
    }
}





@end

