//
//  musicController.m
//  diumoo
//
//  Created by Shanzi on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "controlCenter.h"
#import "preference.h"
#import "controlCenter.h"

controlCenter* sharedCenter;

@implementation controlCenter


-(void) dealloc
{
    [self pause];
    [current release];
    [source release];
    [lock release];
    [sharedCenter release];
    [super dealloc];
}


+(controlCenter*) sharedCenter
{
    if(sharedCenter==nil)
    {
        sharedCenter=[[controlCenter alloc] init];
    }
   return sharedCenter;
}

+(BOOL) tryAuth:(NSDictionary*) userinfo
{
    doubanFMSource* source=[[controlCenter sharedCenter] getSource];
    if(source!=nil) 
    {
        return [source authWithUsername:[userinfo valueForKey:@"username"] andPassword:[userinfo valueForKey:@"password"]];
    }
    return NO;
}

+(void) cleanAuth
{
    [[sharedCenter getSource] authWithUsername:@"" andPassword:@""];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        lock=[[NSLock alloc]init];
        state=0;
        current=nil;
        player=nil;
        source=nil;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(musicEnded:) name:@"player.end" object:nil];
        }
    
    return self;
}

-(BOOL) setPlayer:(id) p
{
    if([lock tryLock]!=YES) 
        return NO;
    
    if(p!=nil){
        player=p;
        state=state|PLAYER_STATE_READY;
    }
    else
    {
        [player pause];
        //[player release];
        player=nil;
        if(state & PLAYER_STATE_READY) 
            state-=PLAYER_STATE_READY;
    }
    [lock unlock];
    return YES;
}

-(BOOL) setSource:(id)s
{
    if([lock tryLock]!=YES) 
        return NO;
    
    if(s!=nil){
        source=s;
        state=state|SOURCE_STATE_READY;
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"controller.sourceChanged" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[s performSelector:@selector(channelList)] ,@"channels",[s performSelector:@selector(sourceName)],@"sourceName" ,nil]];
    }
    else
    {
        [player pause];
        //[source release];
        source=nil;
        if(state & SOURCE_STATE_READY) 
            state-=SOURCE_STATE_READY;
    }
    [lock unlock];
    return YES;
}

-(musicPlayer*) getPlayer
{
    return player;
}

-(doubanFMSource*) getSource
{
    return source;
}

-(BOOL) play_pause
{
    return ([self play] ==YES || [self pause] == YES);
}


-(BOOL) play
{
    #ifdef DEBUG
        NSLog(@"controlCenter play called");
    #endif

    [[NSNotificationCenter defaultCenter] postNotificationName:@"playbuttonpressed" object:nil userInfo:nil];
    
    if([lock tryLock]!=YES) 
        return NO;
    
    if(player!=nil && [player isPlaying]!=YES){
        [player performSelectorOnMainThread:@selector(play) withObject:nil waitUntilDone:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"player.resume" object:nil userInfo:current];
    }
    else 
    {
        [lock unlock];
        return NO;
    }
    [lock unlock];
    return YES; 
}

-(BOOL) pause
{
    #ifdef DEBUG
        NSLog(@"controlCenter pause called");
    #endif
    if([lock tryLock]!=YES) 
        return NO;
    
    if(player != nil && [player isPlaying])
    {
        [player performSelectorOnMainThread:@selector(pause) withObject:nil waitUntilDone:YES];
    }
    else return [lock unlock],NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.paused" object:nil userInfo:nil];  
    return [lock unlock],YES;
}

-(BOOL) skip
{
    #ifdef DEBUG
        NSLog(@"controlCenter skip called");
    #endif
    
    if([lock tryLock]!=YES) return NO;
    if(source!=nil )
    {
        if(current==nil && (current=[source getNewSong])==nil)
        {
            [lock unlock];
            return NO;
        }
        
        NSString* sid=[current valueForKey:@"sid"];
        [sid retain];
        [current release];
        if(player!=nil && ([player pause],(current=[source getNewSongBySkip:sid]))!=nil)
            {
                [current retain];
                [sid release]; 
                [player performSelectorInBackground:@selector(startToPlay:) withObject:current];
                [lock unlock];
                return YES;
            }
        [sid release];
    }
    [lock unlock];
    return NO;
}

-(BOOL) rate
{
    if([lock tryLock]!=YES)
        return NO;
    if(source!=nil && current !=nil && 
        [source rateSongBySid:[current valueForKey:@"sid"]] ) 
        return [lock unlock],YES;
    return [lock unlock],NO;
        
}

-(BOOL) unrate
{
    if([lock tryLock]!=YES)
        return NO;
    if(source!=nil && current !=nil && 
       [source unrateSongBySid:[current valueForKey:@"sid"]] ) 
        return [lock unlock],YES;
    return [lock unlock],NO;
    
}
-(BOOL) bye
{
    if([lock tryLock]!=YES)
        return NO;
    if(source!=nil && current!=nil && player!=nil && (current=[source getNewSongByBye:[current valueForKey:@"sid"]])!=nil)
    {
        [current retain];
        [player performSelectorInBackground:@selector(startToPlay:) withObject:current];
        [lock unlock];
        return YES;
    }
        
    return [lock unlock],NO;
       
}

-(BOOL) changeChannelTo:(NSInteger)channel
{
    #ifdef DEBUG
        NSLog(@"controlCenter changeChannelTo called");
    #endif
    [self pause];
    if([lock tryLock]!=YES)
        return NO;
    [current release];
    current=nil;
    if(player!=nil && source!=nil && (current=([source setChannel:channel],[source getNewSong]))!=nil)
    {
        [current retain];
        [player performSelectorInBackground:@selector(startToPlay:) withObject:current];
        [lock unlock];
        return YES;
    }
    return [lock unlock],NO;
}

-(void) musicEnded:(NSNotification*)n
{
    if(n.object!=nil)
    {
        if(player!=nil && source!=nil && current!=nil && (current = [[source getNewSong]  retain])!=nil)
        {
            [player performSelectorOnMainThread:@selector(startToPlay:) withObject:current waitUntilDone:NO];
            NSLog(@"New Song!");
        }
        else
        {
            NSRunCriticalAlertPanel(NSLocalizedString(@"CON_FAIL", nil), NSLocalizedString(@"RETRY_FAIL", nil), NSLocalizedString(@"KNOWN", nil),nil,nil);
        }
    }
    if([lock tryLock]!=YES) return;
    if(player!=nil && source!=nil && current!=nil && (current =[[source getNewSongWhenEnd:[current valueForKey:@"sid"]]retain])!=nil)
        [player performSelectorOnMainThread:@selector(startToPlay:) withObject:current waitUntilDone:NO];
    [lock unlock];
}


-(void) service:(NSString *)s
{
    if(current==nil) 
        return;
    
    if([s isEqualToString:@"twitter"])
    {
        
        NSString* str=[NSString stringWithFormat:@"#nowplaying %@ - %@ ",[current valueForKey:@"Name"],[current valueForKey:@"Artist"]];
        if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"TwitterDoubanInfo"] integerValue]==NSOnState) str=[str stringByAppendingFormat:@" (豆瓣电台-%@ | %@ ) ",[current valueForKey:@"Channel"],[current valueForKey:@"Store URL"]];
        
        NSPasteboard* pb=[NSPasteboard pasteboardWithUniqueName];
        
        [pb setData:[str dataUsingEncoding:NSUTF8StringEncoding] forType:NSStringPboardType];
        NSPerformService(@"Tweet", pb);
    }
    else if([s isEqualToString:@"google"]||[s isEqualToString:@"lastfm"]){
        NSString* unencode=nil;
        NSInteger type=[[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"GoogleSearchType"] integerValue];
        switch (type) {
            case 1:
                unencode=[NSString stringWithFormat:@"%@+%@",[current valueForKey:@"Name"],[current valueForKey:@"Artist"]];
                break;
            case 2:
                unencode=[NSString stringWithFormat:@"%@+%@+%@",[current valueForKey:@"Name"],[current valueForKey:@"Artist"],[current valueForKey:@"Album"]];
                break;
            default:
                unencode=[current valueForKey:@"Name"];
                break;
        }
        
        CFStringRef encoded=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)unencode, NULL, (CFStringRef)@"!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        
        NSString* site_url;
        if([s isEqualToString:@"google"]){
            site_url = @"google.com/#q=";
        }
        else if ([s isEqualToString:@"lastfm"]){
            site_url = @"www.last.fm/search?q=";
        }
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", site_url, encoded]]];
        CFRelease(encoded);
    }
    else if([s isEqualToString:@"fanfou"] || [s isEqualToString:@"Sina"] || [s isEqualToString:@"Facebook"] )
    {
        NSString* u_name=[NSString stringWithFormat:@"%@ (%@) ",[current valueForKey:@"Name"],[current valueForKey:@"Artist"]];
        CFStringRef name=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)u_name, NULL, (CFStringRef)@"+!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        CFStringRef url=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[current valueForKey:@"Store URL"], NULL, (CFStringRef)@"+!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        CFStringRef detail=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[NSString stringWithFormat:@"(正在收听:豆瓣电台-%@)",[current valueForKey:@"Channel"]], NULL, (CFStringRef)@"+!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        if ([s isEqualToString:@"fanfou"]) {
            [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fanfou.com/sharer?u=%@&d=%@&t=%@",url,detail,name]]];
        }
        else if ([s isEqualToString:@"Sina"]){
            [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://v.t.sina.com.cn/share/share.php?title=%@%@%@",name,detail,url]]];
        }
        else if([s isEqualToString:@"Facebook"])
        {
            [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/sharer.php?u=%@&t=%@",url,name]]];
        }
        
        CFRelease(name);
        CFRelease(url);
        CFRelease(detail);
    
    }
        else
        {
        @try {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[current valueForKey:@"Store URL"]]];
            }
        @catch (NSException *exception) {
            
        }
        
    }
}

@end
