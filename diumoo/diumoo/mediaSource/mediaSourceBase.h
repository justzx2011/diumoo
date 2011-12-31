//
//  mediaSourceBase.h
//  diumoo
//
//  Created by Shanzi on 11-12-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mediaSourceBase : NSObject

-(BOOL) authWithUsername:(NSString*) name andPassword:(NSString*) password;

-(NSString*) sourceName;
-(NSDictionary*) getNewSong;
-(NSDictionary*) getNewSongBySkip:(NSString*) sid;
-(NSDictionary*) getNewSongWhenEnd: (NSString*) sid;
-(NSDictionary*) getNewSongByBye:(NSString*) sid;
-(BOOL) rateSongBySid:(NSString*) sid;
-(BOOL) unrateSongBySid:(NSString*) sid;
-(void) setChannel:(NSInteger) channel;
-(NSInteger) channel;

-(NSArray*) channelList;

@end

