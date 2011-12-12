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
        request=[[[NSMutableURLRequest alloc]init] retain];
        [request setTimeoutInterval:TIMEOUT];
        [request setHTTPShouldHandleCookies:NO];
        
        //初始化lock
        condition=[[NSCondition alloc]init];
        
        //将Cookie设置为空
        cookie=nil;
        
        //初始化两个set
        replacePlaylist = [[NSSet alloc] initWithObjects:NEW,SKIP,BYE, nil];
        recordType = [[NSSet alloc] initWithObjects:RATE,END,SKIP,BYE, nil];
        
        //初始化playlist
        playlist=[[NSMutableArray alloc] initWithCapacity:20];
        
        //初始化h
        h=[[NSMutableString alloc] init];
        
        //将电台设置为上次收听的电台
        if([[NSUserDefaults standardUserDefaults] valueForKey:@"doubanfm.channel"])
            channel=[ [[NSUserDefaults standardUserDefaults]valueForKey:@"doubanfm.channel"]integerValue];
        else channel=0;
        
        //读取电台频道信息
        channelList=[[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dchannels" ofType:@"plist"]] retain];
        
    }
    
    return self;
}

-(BOOL) authWithUsername:(NSString*) name andPassword:(NSString*) password
{
    [condition lock];
    if([name isNotEqualTo:@""] && [password isNotEqualTo:@""]){
        //生成表单body
        NSData* body=[[NSString stringWithFormat:@"alias=%@&form_password=%@&source=radio\n",name,password] dataUsingEncoding:NSUTF8StringEncoding];
        
        //初始化request
        [request setHTTPMethod:@"POST"];
        [request setURL:AUTH_URL];
        [request setHTTPBody:body];
        
        //生成同步请求
        NSHTTPURLResponse* r=nil;
        NSError* e= nil;
        NSData* data=[NSURLConnection sendSynchronousRequest:request returningResponse:&r error:&e];
        
        if(e==NULL){
            NSError* je=nil;
            NSDictionary* obj=[[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&je];
            if(je==NULL && ([[obj valueForKey:@"r"]intValue]==0)) {
                [user_info release];
                user_info=[obj valueForKey:@"user_info"];
                cookie = [NSHTTPCookie cookiesWithResponseHeaderFields:[r allHeaderFields] forURL:[r URL]];
                NSLog(@"%@",cookie);
                [condition unlock];
                return YES;
            }
        }
    }
    [condition unlock];
    return NO;
}
-(BOOL) requestPlaylistWithType:(NSString*)type andSid:(NSInteger)sid
{
        //生成获取列表的参数
        //    | 生成随机数
        long rnd=rand();
        rnd=rnd<MIN_RAND?rnd+MIN_RAND:rnd;
        //    | 生成channel
        NSString* _s=@"";
        NSMutableArray* _cookie=[[NSMutableArray alloc] init];
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
            NSLog(@"%@",dic);
            NSLog(@"%@",[NSHTTPCookie cookieWithProperties:dic]);
           // [_cookie addObject:];
        }
        else _s=[NSString stringWithFormat:@"channel=%d",channel];
        if([type isNotEqualTo:NEW]&&sid!=0)
            _s=[NSString stringWithFormat:@"%@&sid=%d",_s,sid];
        if([type isNotEqualTo:NEW])_s=[NSString stringWithFormat:@"%@&h=%d:%@%@",_s,sid,type,h];
        if([recordType containsObject:type])
            [h appendString:[NSString stringWithFormat:@"%%7C%d:%@",sid,type]];
        
        
        // 构造request
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?type=%@&r=%x&%@",PLAYLIST_URL_STRING,type,rnd,_s]]];
        [request setHTTPMethod:@"GET"];
        [request setHTTPBody:nil];
        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:_cookie]];
        
        NSLog(@"%@",[request URL]);
        
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

-(NSDictionary*) getNewSongByType:(NSString *)t andSid:(NSInteger)sid
{
    int retry=0;
    do{
        [self requestPlaylistWithType:t andSid:sid];
    }
    while([playlist count]==0 && (retry++)<MAX_RETRY_TIMES);
    
    if([playlist count]==0) 
        @throw [NSException exceptionWithName:@"Network" reason:@"Request timeout" userInfo:nil];
        
        NSDictionary* current=[[playlist objectAtIndex:0] retain];
        [playlist removeObjectAtIndex:0];
    NSLog(@"%@",current);
    NSDictionary* currentMusic=nil;
        NSString* art=[current valueForKey:@"artist"];
        if(art==nil) art = [current valueForKey:@"dj_name"];
        currentMusic=[[NSDictionary dictionaryWithObjectsAndKeys:
                      [current valueForKey:@"albumtitle"],@"Album",
                      [current valueForKey:@"album"],@"Store URL",
                      [current valueForKey:@"public_time"],@"Year",
                      art, @"Artist" ,
                      [current valueForKey:@"title"],@"Title",
                      [current valueForKey:@"url"],@"Location",
                      [current valueForKey:@"sid"],@"sid",
                      [current valueForKey:@"picture"],@"picture",
                      [NSNumber numberWithInt:[[current valueForKey:@"length"]intValue]*1000 ],@"Total time",
                      @"Playing",@"Player Info",
                       [current valueForKey:@"like"],@"Like",
                       [current valueForKey:@"rating_avg"],@"Album Rating",
                       nil] retain];
        [current release];
        return currentMusic;
    return nil;
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

-(NSDictionary*) getNewSongBySkip:(NSInteger)sid
{
    [condition lock];
    return [self _quick_unlock:[self getNewSongByType:SKIP andSid:sid]];
}
-(NSDictionary*) getNewSongWhenEnd:(NSInteger)sid
{
    [condition lock];
    return [self _quick_unlock:[self getNewSongByType:END andSid:sid]];
}

-(NSDictionary*) getNewSongByBye:(NSInteger)sid
{
    [condition lock];
    return [self _quick_unlock:[self getNewSongByType:BYE andSid:sid]];
}

-(BOOL) rateSongBySid:(NSInteger)sid
{
    [condition lock];
    BOOL r=[self requestPlaylistWithType:RATE andSid:sid];
    [condition unlock];
    return r;
}

-(BOOL) unrateSongBySid:(NSInteger) sid
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

-(void) setChannel:(NSInteger)c
{
    [condition lock];
    channel=c;
    [condition unlock];
}

-(NSSet*)cans
{
    return [NSSet setWithObjects:@"play",@"next",@"rate",@"bye", nil];
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
    [playlist release];
    [request release];
    [h release];
    [user_info release];
    [condition release];
    [super dealloc];
}

@end
