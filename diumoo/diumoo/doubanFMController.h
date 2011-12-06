//
//  doubanFMController.h
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

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"

@interface doubanFMController : NSObject{
    NSMutableURLRequest* request;
    NSMutableArray* playlist;
    NSMutableString* h;
    NSArray* cookie;
    NSInteger channel;
    NSDictionary* currentMusic;
    NSDictionary* nextMusic;
    NSDictionary* user_info;
    //一个线程锁
    NSLock* lock;
    
    //类别
    NSSet* replacePlaylist;
    NSSet* doNotReplacePlaylist;
    
}

@property (assign,nonatomic) NSDictionary* currentMusic;
@property (assign,nonatomic) NSDictionary* nextMusic;
@property (assign,nonatomic) NSDictionary* user_info;
@property (assign,nonatomic) NSLock* lock;

-(BOOL) authWithUsername:(NSString*) name andPassword:(NSString*) password;
-(BOOL) requestPlaylistWithType:(NSString*)type andSid: (NSString*) sid; 


@end
