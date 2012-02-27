//
//  doubanFMSource.h
//  diumoo
//
//  Created by Shanzi on 11-12-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#define NEW @"n"
#define SKIP @"s"
#define END @"e"
#define PLAYING @"p"
#define RATE @"r"
#define UNRATE @"u"
#define BYE @"b"

#define AUTH_URL [NSURL URLWithString:@"http://douban.fm/j/login"]
#define PLAYLIST_URL_STRING @"http://douban.fm/j/mine/playlist"
#define TIMEOUT 10.0

#define MASK 0xFFFFFF
#define MAX_RETRY_TIMES 10

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "HTMLParser.h"

@interface doubanFMSource : NSObject{
    NSMutableURLRequest* request;
    NSMutableArray* playlist;
    NSMutableString* h;
    
    NSInteger channel;
    NSString* channelName;
    NSArray* channelList;
    
    NSDictionary* user_info;
    
    //一个线程锁
    NSCondition* condition;
    
    //类别
    NSSet* replacePlaylist;
    NSSet* recordType;
    
    BOOL loggedIn;
    NSSet* privateEnables;
    NSSet* publicEnables;
    NSSet* publicWithLoggedInEnables;
    
    
}

-(NSDictionary*) userinfo;

-(BOOL) authWithDictionary:(NSDictionary*) dic;
-(BOOL) requestPlaylistWithType:(NSString*)type andSid:(NSString*)sid; 
-(NSDictionary* ) getNewSongByType:(NSString *)t andSid:(NSString*)sid;
-(id) _quick_unlock:(id) r;
-(void) _back_request:(NSDictionary* ) dic;

//Source 接口
-(NSString*) sourceName;
-(NSDictionary*) getNewSong;
-(NSDictionary*) getNewSongBySkip:(NSString*) sid;
-(NSDictionary*) getNewSongWhenEnd: (NSString*) sid;
-(NSDictionary*) getNewSongByBye:(NSString*) sid;
-(BOOL) rateSongBySid:(NSString*) sid;
-(BOOL) unrateSongBySid:(NSString*) sid;
-(void) setChannel:(NSInteger) channel;

-(NSInteger) channel;
-(BOOL) findChannelName:(NSArray*) list ofChannel:(NSInteger) c;

-(NSArray*) channelList;

@end
