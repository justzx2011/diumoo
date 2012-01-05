//
//  doubanFMSource.m
//  diumoo
//
//  Created by Shanzi on 11-12-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "doubanFMSource.h"

@implementation doubanFMSource

- (id)init
{
    self = [super init];
    if (self) {
        //初始化随机数
        srand((int)time(0));
        
        //初始化 request
        request=[[[NSMutableURLRequest alloc]init] retain] ;
        [request setTimeoutInterval:TIMEOUT];
        [request setHTTPShouldHandleCookies:NO];
        
        //初始化lock
        condition=[[[NSCondition alloc]init] retain] ;
        
        //将Cookie设置为空
        cookie=nil;
        
        //初始化两个set
        replacePlaylist = [[[NSSet alloc] initWithObjects:NEW,SKIP,BYE, nil] retain] ;
        recordType = [[[NSSet alloc] initWithObjects:RATE,END,SKIP,BYE, nil] retain] ;
        
        privateEnables=[[NSSet setWithObjects:@"play",@"next",@"like",@"bye", nil] retain] ;
        publicEnables = [[NSSet setWithObjects:@"play",@"next", nil] retain];
        publicWithLoggedInEnables = [[NSSet setWithObjects:@"play",@"next",@"like", nil] retain];
        
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
        channelList=[[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dchannels" ofType:@"plist"]] retain];
        channelName=nil;
        
    }
    
    return self;
}

-(BOOL) authWithUsername:(NSString*) name andPassword:(NSString*) password
{
    [condition lock];
    if([name isNotEqualTo:@""] && [password isNotEqualTo:@""]){
        //生成表单body
        CFStringRef encodedName=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)name, NULL, (CFStringRef)@"+!*'();:&=$,/?%#[]|", kCFStringEncodingUTF8);
        CFStringRef encodedPass=CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)password, NULL, (CFStringRef)@"+!*'();:&=$,/?%#[]|", kCFStringEncodingUTF8);
        NSData* body=[[NSString stringWithFormat:@"alias=%@&form_password=%@&source=radio\n",encodedName,encodedPass] dataUsingEncoding:NSUTF8StringEncoding];
        CFRelease(encodedName);
        CFRelease(encodedPass);
        
        //初始化request
        [request setHTTPMethod:@"POST"];
        [request setURL:AUTH_URL];
        [request setHTTPBody:body];
        NSArray* array= [[NSArray alloc] init];
        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:array]];
        [array release];
        
        //生成同步请求
        NSHTTPURLResponse* r=nil;
        NSError* e= nil;
        NSData* data=[NSURLConnection sendSynchronousRequest:request returningResponse:&r error:&e];
        if(e==NULL){
            NSError* je=nil;
            NSDictionary* obj=[[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&je];
            if(je==NULL && ([[obj valueForKey:@"r"]intValue]==0)) {
                user_info=[obj valueForKey:@"user_info"];
                cookie = [[NSHTTPCookie cookiesWithResponseHeaderFields:[r allHeaderFields] forURL:[r URL]] retain];
                loggedIn=YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"source.enables" object:nil userInfo:[NSDictionary dictionaryWithObject:(channel==0?privateEnables:publicWithLoggedInEnables) forKey:@"enables"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"source.account" object:nil userInfo:user_info];
                [condition unlock];
                return YES;
            }
        }
    }
    
    loggedIn=NO;
    if(cookie!=nil) [cookie release];
    cookie=nil;
    user_info=nil;
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
    int rnd=rand();
    rnd=rnd<MIN_RAND?rnd+MIN_RAND:rnd;
    //    | 生成channel
    NSString* _s=@"";
    NSMutableArray* _cookie=[[NSMutableArray alloc] init];
    if(cookie!=nil)
        [_cookie addObjectsFromArray:cookie];
    if(channel>10000){
        _s=[NSString stringWithFormat: @"channel=dj&pid=%d",channel];
        NSDictionary* dic=[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSString stringWithFormat:@"%d",channel],
                           NSHTTPCookieValue,
                           @"dj_id",NSHTTPCookieName,
                           @"/",NSHTTPCookiePath,
                           @".douban.fm",NSHTTPCookieDomain
                           ,nil];
        [_cookie addObject:[NSHTTPCookie cookieWithProperties:dic]];
    }
    else _s=[NSString stringWithFormat:@"channel=%d",channel];
    if([type isNotEqualTo:NEW]&& sid!=nil &&[sid isNotEqualTo:@""])
        _s=[NSString stringWithFormat:@"%@&sid=%@",_s,sid];
    if([type isNotEqualTo:NEW])_s=[NSString stringWithFormat:@"%@&h=%@:%@%@",_s,sid,type,h];
    if([recordType containsObject:type])
        [h appendString:[NSString stringWithFormat:@"%%7C%@:%@",sid,type]];
    
    // 构造request
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?type=%@&r=%x&%@",PLAYLIST_URL_STRING,type,rnd,_s]]];
    [request setHTTPMethod:@"GET"];
    [request setHTTPBody:nil];
    [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:_cookie]];
    [_cookie release];

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
                if([replacePlaylist containsObject:type] && [song count]>0)[playlist removeAllObjects];
                [playlist addObjectsFromArray:[list valueForKey:@"song"]];
                
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
    if([playlist count]==0){
        int retry=0;
        do{
            [self requestPlaylistWithType:t andSid:sid];
        }
        while([playlist count]==0 && (retry++)<MAX_RETRY_TIMES);
        
        if([playlist count]==0){
            return nil;
        };
    }
    else [self performSelectorInBackground:@selector(_back_request:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:sid,@"sid",t,@"type", nil ]];
    NSDictionary* current=[[playlist objectAtIndex:0] retain] ;
    [playlist removeObjectAtIndex:0];
    
    NSString* art=[current valueForKey:@"artist"];
    if(art==nil) art = [current valueForKey:@"dj_name"];
    
    NSString* str=[current valueForKey:@"album"];
    if(![str hasPrefix:@"http://"])
        str=[@"http://music.douban.com" stringByAppendingString:str];

    NSDictionary* currentMusic=[[NSDictionary dictionaryWithObjectsAndKeys:
                  [current valueForKey:@"albumtitle"],@"Album",
                  str,@"Store URL",
                  [current valueForKey:@"public_time"],@"Year",
                  art, @"Artist" ,
                  [current valueForKey:@"title"],@"Name",
                  [current valueForKey:@"url"],@"Location",
                  [current valueForKey:@"sid"],@"sid",
                  [[current valueForKey:@"picture"] stringByReplacingOccurrencesOfString:@"mpic" withString:@"lpic"],@"Picture",
                  [NSNumber numberWithInt:[[current valueForKey:@"length"]intValue]*1000 ],@"Total time",
                  channelName,@"Channel",
                  [current valueForKey:@"like"],@"Like",
                  [current valueForKey:@"rating_avg"],@"Album Rating",
                  
                  nil] retain];
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
        channelName=[[NSString stringWithString:@"[>.<]矮油我不认识的兆赫"] retain];
    }
    if(channel==0 && loggedIn==YES) r=privateEnables;
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
    return @"豆瓣电台";
}

-(void) dealloc
{
    [channelList release];
    [cookie release];
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
