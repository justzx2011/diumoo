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
#define TIMEOUT 5

#define MIN_RAND 68719476736
#define MAX_RETRY_TIMES 5

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"

@interface doubanFMSource : NSObject{
    NSMutableURLRequest* request;
    NSMutableArray* playlist;
    NSMutableString* h;
    NSArray* cookie;
    NSInteger channel;
    //NSDictionary* nextMusic;
    NSDictionary* user_info;
    //一个线程锁
    NSCondition* condition;
    //类别
    NSSet* replacePlaylist;
    NSSet* recordType;
    
    NSDictionary* channelList;
    
}
@property(assign,nonatomic) NSDictionary* channelList;

-(BOOL) authWithUsername:(NSString*) name andPassword:(NSString*) password;
-(BOOL) requestPlaylistWithType:(NSString*)type andSid:(NSInteger)sid; 
-(NSDictionary* ) getNewSongByType:(NSString *)t andSid:(NSInteger)sid;
-(id) _quick_unlock:(id) r;

//Source 接口

-(NSDictionary*) getNewSong;
-(NSDictionary*) getNewSongBySkip:(NSInteger) sid;
-(NSDictionary*) getNewSongWhenEnd: (NSInteger) sid;
-(NSDictionary*) getNewSongByBye:(NSInteger) sid;
-(BOOL) rateSongBySid:(NSInteger) sid;
-(BOOL) unrateSongBySid:(NSInteger) sid;
-(void) setChannel:(NSInteger) channel;
-(NSInteger) channel;



@end
