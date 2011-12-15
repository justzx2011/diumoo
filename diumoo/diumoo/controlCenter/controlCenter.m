//
//  musicController.m
//  diumoo
//
//  Created by Shanzi on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "controlCenter.h"

@implementation controlCenter

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        lock=[[[NSLock alloc]init] retain];
        state=0;
        current=nil;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(musicEnded) name:@"player.end" object:nil];
        }
    
    return self;
}

-(BOOL) setPlayer:(id) p
{
    if([lock tryLock]!=YES) return NO;
    if(p!=nil)
        player=[p retain],state=state|PLAYER_STATE_READY;
    else
    {
        [player pause],[player release],player=nil;
        if(state & PLAYER_STATE_READY) state-=PLAYER_STATE_READY;
    }
    if((state & PLAYER_STATE_READY) && (state & SOURCE_STATE_READY)) [self _start_to_play];
    [lock unlock];
    return YES;
}

-(BOOL) setSource:(id)s
{
    if([lock tryLock]!=YES) return NO;
    if(s!=nil){
        source=[s retain];
        state=state|SOURCE_STATE_READY;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"controller.sourceChanged" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[s performSelector:@selector(cans)],@"cans",[s performSelector:@selector(channelList)] ,@"channels",[s performSelector:@selector(sourceName)],@"sourceName" ,nil]];
    }
    else
    {
        [player pause],[source release],source=nil;
        if(state & SOURCE_STATE_READY) state-=SOURCE_STATE_READY;
    }
    if((state & PLAYER_STATE_READY) && (state & SOURCE_STATE_READY))
        if([self _start_to_play]!=YES) return NO;
    [lock unlock];
    return YES;
}

-(id) getPlayer
{
    return player;
}

-(id) getSource
{
    return source;
}

-(BOOL) _start_to_play
{
    [source setChannel:0];
    current=[[source getNewSong] retain];
    if(current!=nil && [player startToPlay:current])
        return YES;
    return NO;
}

-(BOOL) play_pause
{
    return ([self play] ==YES || [self pause] == YES);
}


-(BOOL) play
{
    if([lock tryLock]!=YES) return NO;
    if( player!=nil && [player isPlaying]!=YES)
        [player play],[[NSNotificationCenter defaultCenter] postNotificationName:@"controller.play" object:nil userInfo:current];
    else return [lock unlock],NO;
    return [lock unlock], YES;
}

-(BOOL) pause
{
    if([lock tryLock]!=YES) return NO;
    if(player != nil && [player isPlaying])
        [[NSNotificationCenter defaultCenter]postNotificationName:@"controller.pause" object:nil userInfo:current],[player pause];
    else return [lock unlock],NO;
    return [lock unlock],YES;
}

-(BOOL) skip
{
    if([lock tryLock]!=YES) return NO;
    if(source!=nil && current!=nil )
        if(player!=nil && ([player pause],[current release],(current=[source getNewSongBySkip:[[current valueForKey:@"sid"]integerValue]]))!=nil)
            if( [player respondsToSelector:@selector(startToPlay:)] && [player startToPlay:current])
                return [lock unlock],YES;
    return NO;
}

-(BOOL) rate
{
    if([lock tryLock]!=YES)return NO;
    if(source!=nil && current !=nil && 
        [source rateSongBySid:[[current valueForKey:@"sid"]integerValue]] ) 
        return [[NSNotificationCenter defaultCenter] postNotificationName:@"controller.rate" object:nil userInfo:current],[lock unlock],YES;
    return [lock unlock],NO;
        
}

-(BOOL) unrate
{
    if([lock tryLock]!=YES)return NO;
    if(source!=nil && current !=nil && 
       [source unrateSongBySid:[[current valueForKey:@"sid"]integerValue]] ) 
        return [[NSNotificationCenter defaultCenter] postNotificationName:@"controller.unrate" object:nil userInfo:current],[lock unlock],YES;
    return [lock unlock],NO;
    
}
-(BOOL) bye
{
    if([lock tryLock]!=YES)return NO;
    if(source!=nil && current!=nil && player!=nil
       && ([current release],current=[[source getNewSongByBye:[[current valueForKey:@"sid"] integerValue]] retain])!=nil
       && [player startToPlay:current]
       ) return [lock unlock],YES;
    return [lock unlock],NO;
       
}

-(BOOL) changeChannelTo:(NSInteger)channel
{
    [self pause];
    if([lock tryLock]!=YES)
        return NO;
    if(player!=nil && source!=nil
       && (current=([source setChannel:channel],[source getNewSong]))!=nil
       && [player startToPlay:current]
       )
        return [lock unlock],YES;
    return [lock unlock],NO;
}

-(void) musicEnded
{
    if([lock tryLock]!=YES) return;
    if(player!=nil 
       && source!=nil
       && current!=nil
       && ([current release],current = [[source getNewSongWhenEnd:[[current valueForKey:@"sid"] integerValue]] retain])!=nil)
        [player startToPlay: current];
    [lock unlock];
}





-(void) dealloc
{
    [self pause];
    [player release];
    [source release];
    [current release];
    [lock release];
    [super dealloc];
}

@end
