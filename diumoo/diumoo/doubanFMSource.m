//
//  doubanFMController.m
//  diumoo
//
//  Created by Shanzi on 11-12-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "doubanFMController.h"

@implementation doubanFMController
@synthesize /*currentMusic,nextMusic,*/lock,user_info;

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
        lock =[[[NSLock alloc] init] retain];
        
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
        else channel=1;
    }
    
    return self;
}

-(BOOL) authWithUsername:(NSString*) name andPassword:(NSString*) password
{
    if([name isNotEqualTo:@""] && [password isNotEqualTo:@""] && [lock tryLock]){
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
                [lock unlock];
                return YES;
            }
        }
        [lock unlock];
    }
    return NO;
}
-(BOOL) requestPlaylistWithType:(NSString*)type andSid: (NSNumber*) sid
{
    if([lock tryLock]){
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
            [_cookie addObject:[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:channel] forKey:@"dj_id"]]];
        }
        else _s=[NSString stringWithFormat:@"channel=%d",channel];
        if([sid intValue]!=0 )
            _s=[NSString stringWithFormat:@"%@&sid=%@",_s,sid];
        if([type isNotEqualTo:NEW])_s=[NSString stringWithFormat:@"%@&h=%@:%@%@",_s,sid,type,h];
        if([recordType containsObject:type])
            [h appendString:[NSString stringWithFormat:@"%%7C%@:%@",sid,type]];
        
        
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
                    //NSLog(@"%@",playlist);
                    [lock unlock];
                    return YES;
                }
                
            }
        }
        [lock unlock];
    }
    return NO;
}

-(NSDictionary*) getNewSongByType:(NSString *)t andSid:(NSNumber*)sid
{
    int retry=0;
    do [self requestPlaylistWithType:t andSid:sid];
    while([playlist count]==0 && (retry++)<MAX_RETRY_TIMES);
        
    if([lock tryLock]){
        if([playlist count]==0) 
            @throw [NSException exceptionWithName:@"Network" reason:@"Request timeout" userInfo:nil];
        NSDictionary* current=[playlist objectAtIndex:0];
        [playlist removeObjectAtIndex:0];
        [currentMusic release];
        currentMusic=[[NSDictionary dictionaryWithObjectsAndKeys:
                      [current valueForKey:@"albumtitle"],@"Album",
                      [current valueForKey:@"rating_avg"],@"Album Rating",
                      [current valueForKey:@"album"],@"Store URL",
                      [current valueForKey:@"public_time"],@"Year",
                      [current valueForKey:@"artist"], @"Artist" ,
                      [current valueForKey:@"title"],@"Title",
                      [current valueForKey:@"url"],@"Location",
                      [current valueForKey:@"sid"],@"sid",
                      [NSNumber numberWithInt:[[current valueForKey:@"length"]intValue]*1000 ],@"Total time",
                      @"Playing",@"Player Info",
                       nil] retain];
        [lock unlock];
        return currentMusic;
    }
    return nil;
}

-(void) play
{
    if(player==nil ){
        @try {
            //得到一首新歌
            [self getNewSongByType:NEW andSid:0];
            
            //将Controller上锁，以免在此过程中player被改变
            if(![lock tryLock]) return;
            NSError* err=nil;
            player=[[musicPlayer alloc] initWithURL:[NSURL URLWithString:[currentMusic valueForKey:@"Location"]] error:&err];
            
            //尝试初始化player之后解除线程锁
            [lock unlock];
            
            //对初始化结果进行测试，如果player初始化失败，则抛出错误
            if(err==NULL) [player autoplay];
            else @throw [NSException exceptionWithName:@"Player" reason:@"Can not init player with url" userInfo:nil];

        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
    }
    else
        if([lock tryLock]) [player play],[player resumeVolume],[lock unlock];
}


-(void) dealloc
{
    [lock lock];
    [cookie release];
    [currentMusic release];
    //[nextMusic release];
    [replacePlaylist release];
    [recordType release];
    [playlist release];
    [request release];
    [h release];
    [user_info release];
    [lock release];
    [super dealloc];
}

@end
