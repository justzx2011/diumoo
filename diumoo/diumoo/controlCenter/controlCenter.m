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
        lock=[[NSLock alloc]init] ;
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
    [lock unlock];
    return YES;
}

-(BOOL) setSource:(id)s
{
    if([lock tryLock]!=YES) return NO;
    if(s!=nil){
        source=[s retain];
        state=state|SOURCE_STATE_READY;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"controller.sourceChanged" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[s performSelector:@selector(channelList)] ,@"channels",[s performSelector:@selector(sourceName)],@"sourceName" ,nil]];
    }
    else
    {
        [player pause],[source release],source=nil;
        if(state & SOURCE_STATE_READY) state-=SOURCE_STATE_READY;
    }
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

-(BOOL) startToPlay
{
    [source setChannel:0];
    current=[[source getNewSong] retain];
    if(current!=nil )
        return  [player performSelectorOnMainThread:@selector(startToPlay:) withObject:current waitUntilDone:NO],YES;
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
        [player performSelectorOnMainThread:@selector(play) withObject:nil waitUntilDone:NO];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"controller.play" object:nil userInfo:current];
    else return [lock unlock],NO;
    return [lock unlock], YES;
}

-(BOOL) pause
{
    if([lock tryLock]!=YES) return NO;
    if(player != nil && [player isPlaying])
    {
      //  [[NSNotificationCenter defaultCenter]postNotificationName:@"controller.pause" object:nil userInfo:current];
        [player performSelectorOnMainThread:@selector(pause) withObject:nil waitUntilDone:NO];
    }
    else return [lock unlock],NO;
    return [lock unlock],YES;
}

-(BOOL) skip
{
    if([lock tryLock]!=YES) return NO;
    if(source!=nil && current!=nil )
        if(player!=nil && ([player pause],[current release],(current=[source getNewSongBySkip:[[current valueForKey:@"sid"]integerValue]]))!=nil)
            if( [player respondsToSelector:@selector(startToPlay:)])
            {
                [player performSelectorOnMainThread:@selector(startToPlay:) withObject:current waitUntilDone:NO];
                [lock unlock];
                return YES;
            }
    [lock unlock];
    return NO;
}

-(BOOL) rate
{
    if([lock tryLock]!=YES)return NO;
    if(source!=nil && current !=nil && 
        [source rateSongBySid:[[current valueForKey:@"sid"]integerValue]] ) 
        return [lock unlock],YES;
        //return [[NSNotificationCenter defaultCenter] postNotificationName:@"controller.rate" object:nil userInfo:current],[lock unlock],YES;
    return [lock unlock],NO;
        
}

-(BOOL) unrate
{
    if([lock tryLock]!=YES)return NO;
    if(source!=nil && current !=nil && 
       [source unrateSongBySid:[[current valueForKey:@"sid"]integerValue]] ) 
        return [lock unlock],YES;
       // return [[NSNotificationCenter defaultCenter] postNotificationName:@"controller.unrate" object:nil userInfo:current],[lock unlock],YES;
    return [lock unlock],NO;
    
}
-(BOOL) bye
{
    if([lock tryLock]!=YES)return NO;
    if(source!=nil && current!=nil && player!=nil
       && ([current release],current=[[source getNewSongByBye:[[current valueForKey:@"sid"] integerValue]] retain])!=nil)
    {
        [player performSelectorOnMainThread:@selector(startToPlay:) withObject:current waitUntilDone:NO];
        [lock unlock];
        return YES;
    }
        
    return [lock unlock],NO;
       
}

-(BOOL) changeChannelTo:(NSInteger)channel
{
    [self pause];
    if([lock tryLock]!=YES)
        return NO;
    if(player!=nil && source!=nil
       && (current=([source setChannel:channel],[source getNewSong]))!=nil)
    {
        [player startToPlay:current];
        [lock unlock];
        return YES;
    }
        
    return [lock unlock],NO;
}

-(void) musicEnded
{
    if([lock tryLock]!=YES) return;
    if(player!=nil 
       && source!=nil
       && current!=nil
       && ([current release],current = [[source getNewSongWhenEnd:[[current valueForKey:@"sid"] integerValue]] retain])!=nil)
        [player performSelectorOnMainThread:@selector(startToPlay:) withObject:current waitUntilDone:NO];
    [lock unlock];
}


-(void) service:(NSString *)s
{
    if(current==nil) return;
    if([s isEqualToString:@"twitter"])
    {
        
        NSString* str=[NSString stringWithFormat:@"#nowplaying %@ - %@ ",[current valueForKey:@"Name"],[current valueForKey:@"Artist"]];
        
        NSPasteboard* pb=[NSPasteboard pasteboardWithUniqueName];
        
        [pb setData:[str dataUsingEncoding:NSUTF8StringEncoding] forType:NSStringPboardType];
        NSPerformService(@"Tweet", pb);
    }
    else{
        NSString* unencode=[NSString stringWithFormat:@"%@+%@",[current valueForKey:@"Name"],[current valueForKey:@"Artist"]];
        CFStringRef encoded=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)unencode, NULL, (CFStringRef)@"!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://google.com/#q=%@",encoded]]];
        CFRelease(encoded);
    }
}



-(void) dealloc
{
    [self pause];
    [current release];
    [lock release];
    [super dealloc];
}

@end
