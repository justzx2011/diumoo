//
//  musicController.m
//  diumoo
//
//  Created by Shanzi on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "controlCenter.h"
#import "preference.h"

controlCenter* sharedCenter;

@implementation controlCenter

+(controlCenter*) sharedCenter
{
    if(sharedCenter==nil)
        sharedCenter= [[[controlCenter alloc] init] retain];
   return sharedCenter;
}
+(BOOL) tryAuth:(NSDictionary*) dic
{
    doubanFMSource* source=[[controlCenter sharedCenter] getSource];
    if(source!=nil) return [source authWithUsername:[dic valueForKey:@"username"] andPassword:[dic valueForKey:@"password"]];
    return NO;
}
+(void) cleanAuth
{
    [[[controlCenter sharedCenter] getSource] authWithUsername:@"" andPassword:@""];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        lock=[[[NSLock alloc]init] retain];
        state=0;
        current=nil;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(musicEnded:) name:@"player.end" object:nil];
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


-(BOOL) play_pause
{
    return ([self play] ==YES || [self pause] == YES);
}


-(BOOL) play
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playbuttonpressed" object:nil userInfo:nil];
    if([lock tryLock]!=YES) return NO;
    if( player!=nil && [player isPlaying]!=YES)
        [player performSelectorOnMainThread:@selector(play) withObject:nil waitUntilDone:NO];

    else return [lock unlock],NO;
    return [lock unlock], YES;
}

-(BOOL) pause
{
    if([lock tryLock]!=YES) return NO;
    if(player != nil && [player isPlaying])
    {
        [player performSelectorOnMainThread:@selector(pause) withObject:nil waitUntilDone:YES];
    }
    else return [lock unlock],NO;
    return [lock unlock],YES;
}

-(BOOL) skip
{
    if([lock tryLock]!=YES) return NO;
    if(source!=nil )
    {
        if(current==nil && (current=[[source getNewSong]retain])==nil) 
        {
            [lock unlock];
            return NO;
        }
        NSString* sid=[[current valueForKey:@"sid"] retain];
        [current release];
        if(player!=nil && ([player pause],(current=[[source getNewSongBySkip:sid ] retain]))!=nil)
            {
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
    if([lock tryLock]!=YES)return NO;
    if(source!=nil && current !=nil && 
        [source rateSongBySid:[current valueForKey:@"sid"]] ) 
        return [lock unlock],YES;
    return [lock unlock],NO;
        
}

-(BOOL) unrate
{
    if([lock tryLock]!=YES)return NO;
    if(source!=nil && current !=nil && 
       [source unrateSongBySid:[current valueForKey:@"sid"]] ) 
        return [lock unlock],YES;
    return [lock unlock],NO;
    
}
-(BOOL) bye
{
    if([lock tryLock]!=YES)return NO;
    if(source!=nil && current!=nil && player!=nil
       && ([current release],current=[[source getNewSongByBye:[current valueForKey:@"sid"]] retain] )!=nil)
    {
        
        [player performSelectorInBackground:@selector(startToPlay:) withObject:current];
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
    [current release];
    current=nil;
    if(player!=nil && source!=nil
       && (current=([source setChannel:channel],[source getNewSong]))!=nil)
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
        if(player!=nil 
           && source!=nil
           && current!=nil
           && ([current release],current = [[source getNewSong]  retain])!=nil)
            [player performSelectorOnMainThread:@selector(startToPlay:) withObject:current waitUntilDone:NO];
        else
        {
            NSRunCriticalAlertPanel(@"连接失败", @"试图从豆瓣电台获取音乐失败！播放将停止，请检查您的网络，您可以尝试点击下一首歌重试。", @"知道了",nil,nil);
        }
    }
    if([lock tryLock]!=YES) return;
    if(player!=nil 
       && source!=nil
       && current!=nil
       && ([current release],current = [[source getNewSongWhenEnd:[current valueForKey:@"sid"]]  retain])!=nil)
        [player performSelectorOnMainThread:@selector(startToPlay:) withObject:current waitUntilDone:NO];
    [lock unlock];
}


-(void) service:(NSString *)s
{
    if(current==nil) return;
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
    else if([s isEqualToString:@"fanfou"])
    {
        NSString* u_name=[NSString stringWithFormat:@"%@ (%@)",[current valueForKey:@"Name"],[current valueForKey:@"Artist"]];
        CFStringRef name=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)u_name, NULL, (CFStringRef)@"+!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        CFStringRef url=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[current valueForKey:@"Store URL"], NULL, (CFStringRef)@"+!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        CFStringRef detail=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[NSString stringWithFormat:@"(正在收听:豆瓣电台-%@)",[current valueForKey:@"Channel"]], NULL, (CFStringRef)@"+!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fanfou.com/sharer?u=%@&d=%@&t=%@",url,detail,name]]];
        CFRelease(name);
        CFRelease(url);
        CFRelease(detail);
    
    }
    else if([s isEqualToString:@"Sina"])
    {
        NSString* u_name=[NSString stringWithFormat:@"%@ (%@)",[current valueForKey:@"Name"],[current valueForKey:@"Artist"]];
        CFStringRef name=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)u_name, NULL, (CFStringRef)@"+!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        CFStringRef url=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[current valueForKey:@"Store URL"], NULL, (CFStringRef)@"+!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        //CFStringRef detail=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[NSString stringWithFormat:@"(正在收听:豆瓣电台-%@)",[current valueForKey:@"Channel"]], NULL, (CFStringRef)@"+!*'();:@&=$,/?%#[]", kCFStringEncodingUTF8);
        [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://v.t.sina.com.cn/share/share.php?title=%@%@",name,url]]];
        CFRelease(name);
        CFRelease(url);
        //CFRelease(detail);

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



-(void) dealloc
{
    [self pause];
    [current release];
    [lock release];
    [super dealloc];
}

@end
