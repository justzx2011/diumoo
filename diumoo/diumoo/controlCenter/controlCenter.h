//
//  musicController.h
//  diumoo
//
//  Created by Shanzi on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "doubanFMSource.h"
#import "diumooPlayer.h"

#define PLAYER_STATE_READY (1)
#define SOURCE_STATE_READY (1<<1)

@interface controlCenter : NSObject
{
    diumooPlayer* player;
    doubanFMSource* source;
    NSDictionary* current;
    
    NSLock* lock;
    
    NSInteger state;
    
}

+(controlCenter*) sharedCenter;
+(BOOL) tryAuth:(NSDictionary*) userinfo;
+(void) cleanAuth;

-(void) musicEnded:(NSNotification*)n;
-(BOOL) setPlayer:(diumooPlayer*) p;
-(BOOL) setSource:(doubanFMSource*) s;
-(diumooPlayer*) getPlayer;
-(doubanFMSource*) getSource;


-(BOOL) play_pause;
-(BOOL) play;
-(BOOL) pause;
-(BOOL) skip;
-(BOOL) rate;
-(BOOL) unrate;
-(BOOL) bye;
-(BOOL) changeChannelTo:(NSInteger) channel;

-(void) service:(NSString*)s;

@end
