//
//  doubanFMController.m
//  diumoo
//
//  Created by Shanzi on 11-12-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "doubanFMController.h"

@implementation doubanFMController
@synthesize currentMusic,nextMusic,lock,user_info;

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
        replacePlaylist = [[NSSet alloc] initWithObjects:NEW,SKIP,UNRATE,BYE, nil];
        doNotReplacePlaylist = [[NSSet alloc] initWithObjects:END,RATE,PLAYING, nil];
        
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
-(BOOL) requestPlaylistWithType:(NSString*)type andSid: (NSString*) sid
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
        if([type isEqualToString:@"n"] && [sid isNotEqualTo:@""]) _s=[NSString stringWithFormat:@"%@&sid=%@",_s,sid];
        if([h length]>0 ) _s=[NSString stringWithFormat:@"%@&%@",_s,h];
        
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
                NSLog(@"%@",list);
                if([[list valueForKey:@"r"] intValue]==0)
                {
                    NSArray* song=[list valueForKey:@"song"];
                    if([replacePlaylist containsObject:type] && [song count]>0)[playlist removeAllObjects];
                    [playlist addObjectsFromArray:[list valueForKey:@"song"]];
                   // if([song count]==0 && [playlist count]==0)/*somecode to change dj fm*/;
                    [lock unlock];
                    return YES;
                }
                
            }
        }
        [lock unlock];
    }
    return NO;
}

-(void) dealloc
{
    [lock lock];
    [cookie release];
    [currentMusic release];
    [nextMusic release];
    [replacePlaylist release];
    [doNotReplacePlaylist release];
    [nextMusic release];
    [playlist release];
    [request release];
    [h release];
    [user_info release];
    [lock release];
    [super dealloc];
}

@end
