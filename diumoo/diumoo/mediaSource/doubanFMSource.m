//
//  doubanFMSource.m
//  diumoo
//
//  Created by Shanzi on 11-12-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "doubanFMSource.h"
#import "listUpdater.h"

@implementation doubanFMSource

- (id)init
{
    self = [super init];
    if (self) {
        //初始化随机数
        srand((int)time(0));
        
        //初始化 request
        request=[[NSMutableURLRequest alloc]init];
        [request setTimeoutInterval:TIMEOUT];
        [request setHTTPShouldHandleCookies:YES];
        
        //初始化lock
        condition=[[NSCondition alloc]init];
        
        //初始化两个set
        replacePlaylist = [[[NSSet alloc] initWithObjects:NEW,SKIP,BYE, nil] retain] ;
        recordType = [[[NSSet alloc] initWithObjects:RATE,END,SKIP,BYE, nil] retain] ;
        
        privateEnables=[[NSSet setWithObjects:@"play",@"next",@"like",@"bye",@"private", nil] retain] ;
        publicEnables = [[NSSet setWithObjects:@"play",@"next", nil] retain];
        publicWithLoggedInEnables = [[NSSet setWithObjects:@"play",@"next",@"like",@"private", nil] retain];
        
        //初始化playlist
        playlist=[[[NSMutableArray alloc] initWithCapacity:20] retain];
        
        //初始化h
        h=[[[NSMutableString alloc] init] retain];
        
        loggedIn = NO;
        
        //将电台设置为上次收听的电台
        if([[NSUserDefaults standardUserDefaults] valueForKey:@"doubanfm.channel"])
            channel=[ [[NSUserDefaults standardUserDefaults]valueForKey:@"doubanfm.channel"]integerValue];
        else channel=0;
        
        //读取电台频道信息
        
        channelList=[getChannelList() retain];
        
        channelName=nil;
        
    }
    
    return self;
}

-(BOOL) authWithDictionary:(NSDictionary *)dic
{
    
    [condition lock];
    
#ifdef DEBUG
NSLog(@"%@",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:AUTH_URL]);
#endif
    
    NSString* name=nil,*password=nil,*captcha=nil,*captcha_code=nil;
    if(dic!=nil){
        name=[dic valueForKey:@"username"];
        password=[dic valueForKey:@"password"];
        captcha=[dic valueForKey:@"captcha"];
        captcha_code=[dic valueForKey:@"captcha_code"];
        if(name && password && [name length]>0 && [password length]>0){
            //生成表单body
            if(!captcha_code && !captcha){
                captcha_code=@"";
                captcha=@"";
            }
            CFStringRef encodedName=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)name, NULL, (CFStringRef)@"+!*'();:&=$,/?%#[]|", kCFStringEncodingUTF8);
            CFStringRef encodedPass=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)password, NULL, (CFStringRef)@"+!*'();:&=$,/?%#[]|", kCFStringEncodingUTF8);
            CFStringRef encodedCaptcha=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)captcha, NULL, (CFStringRef)@"+!*'();:&=$,/?%#[]|", kCFStringEncodingUTF8);
            NSData* body=[[NSString stringWithFormat:@"remember=on&source=radio&alias=%@&form_password=%@&captcha_solution=%@&captcha_id=%@",encodedName,encodedPass,encodedCaptcha,captcha_code] dataUsingEncoding:NSUTF8StringEncoding];
            CFRelease(encodedName);
            CFRelease(encodedPass);
            CFRelease(encodedCaptcha);
            
            //初始化request
            [request setHTTPMethod:@"POST"];
            [request setURL:AUTH_URL];
            [request setHTTPBody:body];
            
            if([captcha_code length]>0){
                NSArray* array= [[NSArray alloc] init];
                [request setHTTPShouldHandleCookies:NO];
                [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:array]];
                [array release];
            }
            
            //生成同步请求
            NSHTTPURLResponse* r=nil;
            NSError* e= nil;
            NSData* data=[NSURLConnection sendSynchronousRequest:request returningResponse:&r error:&e];
            loggedIn=NO;
            if(e==NULL){
                NSError* je=nil;
                NSDictionary* obj=[[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&je];
                if(je==NULL ) {
                    if([[obj valueForKey:@"r"]intValue]==0){
                        user_info=[obj valueForKey:@"user_info"];
#ifdef DEBUG
NSLog(@"user_info:%@",user_info);
#endif
                        if(user_info){
                            //[[NSUserDefaults standardUserDefaults] setValue:user_info forKey:@"user_info"];
                            NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[r allHeaderFields] forURL:[r URL]] ;
                            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:[r URL] mainDocumentURL:nil];
                            loggedIn=YES;
                        }
                        else loggedIn=NO;
                    }
                    
                }
                else if(r.statusCode==200)
                {
                    //----------------------解析html以获取用户信息----------------------------
                    
                    NSError* err=nil;

                    HTMLParser* parser=[[HTMLParser alloc]initWithData:data error:&err];
                    if(err==NULL){
                        HTMLNode* bodynode=[parser body];
                        HTMLNode* total=[[bodynode findChildOfClass:@"stat-total"] findChildTag:@"i"];
                        HTMLNode* liked=[[bodynode findChildOfClass:@"stat-liked"] findChildTag:@"i"];
                        HTMLNode* banned=[[bodynode findChildOfClass:@"stat-banned"] findChildTag:@"i"];
                        HTMLNode* user=[[bodynode findChildOfClass:@"login-usr"] findChildTag:@"a"];
                        if(total && liked && banned && user){
                            NSString* userlink=[user getAttributeNamed:@"href"];
                            HTMLParser* imgParser=[[HTMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:userlink] error:&err];

                            if(err==NULL){

                                HTMLNode* userfacenode=[[imgParser body] findChildOfClass:@"userface"];
                                if(userfacenode){
                                    user_info=[NSDictionary dictionaryWithObjectsAndKeys:[user contents],@"name",
                                              [NSDictionary dictionaryWithObjectsAndKeys:
                                               [total contents],@"played",
                                               [liked contents],@"liked",
                                               [banned contents],@"banned",nil],@"play_record",
                                              userlink,@"url",
                                              [userfacenode getAttributeNamed:@"src"],@"userface",
                                              nil];
                                    loggedIn=YES;
                                }
                            }
                            [imgParser release];
                        }
                    }
                    else{
                        NSLog(@"Login Error!");
                    }
                    
                    //--------------------------------------------------------------------
                    
                    [parser release];
                }
                
                
                
                r=nil;
                e=nil;
                if(loggedIn){
                    
                    NSURLRequest* icon1=nil;
                    if([user_info valueForKey:@"userface"])
                        icon1=[NSURLRequest requestWithURL:[NSURL URLWithString:[user_info valueForKey:@"userface"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0];
                    else icon1=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img3.douban.com/icon/u%@.jpg",[user_info valueForKey:@"id"]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0];
                    
                    NSData* icondata=[NSURLConnection sendSynchronousRequest:icon1 returningResponse:&r error:&e];
                    
                    if(e==NULL){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"source.enables" object:icondata userInfo:[NSDictionary dictionaryWithObject:(channel==0?privateEnables:publicWithLoggedInEnables) forKey:@"enables"]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"source.account" object:icondata userInfo:user_info];
                    }
                    else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"source.enables" object:nil userInfo:[NSDictionary dictionaryWithObject:(channel==0?privateEnables:publicWithLoggedInEnables) forKey:@"enables"]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"source.account" object:nil userInfo:user_info];
                    }
                    
                    
                    [condition unlock];
                    return YES;
                }
                
            }
        }
    }
    for (NSHTTPCookie* cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:AUTH_URL]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    user_info=nil;
    loggedIn=NO;
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"user_info"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"source.enables" object:nil userInfo:[NSDictionary dictionaryWithObject:publicEnables forKey:@"enables"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"source.account" object:nil userInfo:user_info];
    
    [condition unlock];
    return NO;
}

-(NSDictionary*) userinfo
{
    return user_info;
}

-(BOOL) requestPlaylistWithType:(NSString*)type andSid:(NSString*)sid
{
    //生成获取列表的参数
    //    | 生成随机数
    int rnd1=rand()&0xfffff;
    int rnd2=rand()&0xfffff;
    char rnds[11]={0};
    sprintf(rnds, "%5x%5x",rnd1,rnd2);
    for(int i=0;i<10;i++) if(rnds[i]==' ') rnds[i]='0';
    
    //    | 生成channel
    NSString* _s=@"";
    if(channel>10000)
    {
        _s=[NSString stringWithFormat: @"channel=dj&pid=%d",channel];
    }
    else _s=[NSString stringWithFormat:@"channel=%d",channel];
    if([type isNotEqualTo:NEW]&& sid!=nil &&[sid isNotEqualTo:@""])
        _s=[NSString stringWithFormat:@"%@&sid=%@",_s,sid];
    if([type isNotEqualTo:NEW] )_s=[NSString stringWithFormat:@"%@&h=%@:%@%@",_s,sid,type,h];
    if([recordType containsObject:type])
        [h appendString:[NSString stringWithFormat:@"%%7C%@:%@",sid,type]];
    
    // 构造request
    [request setHTTPShouldHandleCookies:YES];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?type=%@&r=%s&%@",PLAYLIST_URL_STRING,type,rnds,_s]]];
    [request setHTTPMethod:@"GET"];
    [request setHTTPBody:nil];
    
#ifdef DEBUG
    NSLog(@"Playlist Request URL: %@",[NSString stringWithFormat:@"%@?type=%@&r=%s&%@",PLAYLIST_URL_STRING,type,rnds,_s]);
#endif
    
    // 发送请求
    NSHTTPURLResponse* r=nil;
    NSError* e=nil;
    NSData* data=[NSURLConnection sendSynchronousRequest:request returningResponse:&r error:&e];
    if(e==NULL)
    {
        NSError* je=nil;
        NSDictionary* list=[[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&je];
        if(je==NULL)
        {
            if([[list valueForKey:@"r"] intValue]==0)
            {
                NSArray* song=[list valueForKey:@"song"];
#ifdef DEBUG
                NSLog(@"list = %@",[list valueForKey:@"song"]);
#endif
                if([replacePlaylist containsObject:type] && [song count]>0){
                    [playlist removeAllObjects];
                }
                [playlist addObjectsFromArray:song];
                return YES;
            }
            
        }
    }
    
    return NO;
}

-(void) _back_request:(NSDictionary* ) dic
{
    [self requestPlaylistWithType:[dic valueForKey:@"type"] andSid:[dic valueForKey:@"sid"]];
}

-(NSDictionary*) getNewSongByType:(NSString *)t andSid:(NSString*)sid
{
    NSLog(@"playlist count = %d",[playlist count]);
    if([playlist count]==0){
        [self requestPlaylistWithType:t andSid:sid];
        int retry=0;
        while([playlist count]==0 && (retry++)<MAX_RETRY_TIMES){
            [self requestPlaylistWithType:NEW andSid:@""];
        }
        if([playlist count]==0){
            return nil;
        };
    }
    //else [self performSelectorInBackground:@selector(_back_request:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:sid,@"sid",t,@"type", nil ]];
    
     NSDictionary *current=[[playlist objectAtIndex:0] retain];
    [playlist removeObjectAtIndex:0];
    NSString* subtype=nil;
    while ((subtype=[current valueForKey:@"subtype"]) && [subtype isEqualToString:@"T"]) {
        //NSLog(@"ADs filter log:\nsubtype = %@,length = %d\ncurrent = %@",[current valueForKey:@"subtype"],[[current valueForKey:@"subtype"] length],current);
        [current release];
        current = [[playlist objectAtIndex:0] retain];
        [playlist removeObjectAtIndex:0];
    }
    
    NSString* art=[current valueForKey:@"artist"];
    if(art==nil) 
        art = [current valueForKey:@"dj_name"];
    
    NSString* str=[current valueForKey:@"album"];
    if(![str hasPrefix:@"http://"])
        str=[@"http://music.douban.com" stringByAppendingString:str];


    NSDictionary* currentMusic=[NSDictionary dictionaryWithObjectsAndKeys:
                  [current valueForKey:@"albumtitle"],@"Album",
                  str,@"Store URL",
                  [current valueForKey:@"public_time"],@"Year",
                  art, @"Artist" ,
                  [current valueForKey:@"title"],@"Name",
                  [current valueForKey:@"url"],@"Location",
                  [current valueForKey:@"sid"],@"sid",
                  [[current valueForKey:@"picture"] stringByReplacingOccurrencesOfString:@"mpic" withString:@"lpic"],@"Picture",
                  [NSNumber numberWithInt:[[current valueForKey:@"length"]intValue]*1000 ],@"Total Time",
                  channelName,@"Channel",
                  [current valueForKey:@"like"],@"Like",
                  [current valueForKey:@"rating_avg"],@"Album Rating",
                  
                  nil];
    [current release];
    return currentMusic;    
}

-(id) _quick_unlock:(id)r
{
    [condition unlock];
    return r;
}

-(NSDictionary*) getNewSong
{
    [condition lock];
    return [self _quick_unlock:[self getNewSongByType:NEW andSid:0]];
}

-(NSDictionary*) getNewSongBySkip:(NSString*)sid
{
    [condition lock];
    return [self _quick_unlock:[self getNewSongByType:SKIP andSid:sid]];
}
-(NSDictionary*) getNewSongWhenEnd:(NSString*)sid
{
    [condition lock];
    return [self _quick_unlock:[self getNewSongByType:END andSid:sid]];
}

-(NSDictionary*) getNewSongByBye:(NSString*)sid
{
    [condition lock];
    return [self _quick_unlock:[self getNewSongByType:BYE andSid:sid]];
}

-(BOOL) rateSongBySid:(NSString*)sid
{
    [condition lock];
    BOOL r=[self requestPlaylistWithType:RATE andSid:sid];
    [condition unlock];
    return r;
}

-(BOOL) unrateSongBySid:(NSString*) sid
{
    [condition lock];
    BOOL r=[self requestPlaylistWithType:UNRATE andSid:sid];
    [condition unlock];
    return r;
}

-(NSInteger) channel
{
    return channel;
}

-(BOOL) findChannelName:(NSArray*) list ofChannel:(NSInteger) c
{
    if(c==0){
        if(channelName){[channelName release];channelName=nil;}
        channelName=[@"私人兆赫" retain];
        return YES;
    }
    else if(c==-3)
    {
        if(channelName){[channelName release];channelName=nil;}
        channelName=[@"红心兆赫" retain];
        return YES;

    }
    if(list==nil) return NO;
    for (NSDictionary* dic in list) {
        @try {
            id n;
            if((n=[dic valueForKey:@"channel_id"])!=nil && [n integerValue]==c  && [dic valueForKey:@"name"]!=nil){
                
                if(channelName !=nil) {[channelName release];channelName=nil;}
                
                channelName=[[NSString stringWithString:[dic valueForKey:@"name"]]retain];
                return YES;
                
            }
            if([self findChannelName:[dic valueForKey:@"channels"] ofChannel:c])
                return YES;
            if([self findChannelName:[dic valueForKey:@"sub"] ofChannel:c])
                return YES;
        }
        @catch (NSException *exception) {
            continue;
        }
        
    }
    
    return  NO;
}

-(void) setChannel:(NSInteger)c
{
    NSSet* r=nil;
    [condition lock];
    channel=c;
    if(![self findChannelName:channelList ofChannel:c])
    {
        if(channelName!=nil) [channelName release];
        channelName=[[NSString stringWithString:NSLocalizedString(@"UNKNOWN_CHAN", nil)] retain];
    }
    if(channel<=0 && loggedIn==YES) r=privateEnables;
    else if(loggedIn==YES) r=publicWithLoggedInEnables;
    else r=publicEnables;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"source.enables" object:nil userInfo:[NSDictionary dictionaryWithObject:r forKey:@"enables"]];
    [playlist removeAllObjects];
    [condition unlock];
}


-(NSArray*) channelList
{
    return channelList;
}

-(NSString*) sourceName
{
    return NSLocalizedString(@"DOUBAN_FM", nil);
}

-(void) dealloc
{
    [channelList release];
    [replacePlaylist release];
    [recordType release];
    [privateEnables release];
    [publicEnables release];
    [playlist release];
    [request release];
    [h release];
    [user_info release];
    [condition release];
    [super dealloc];
}

@end
