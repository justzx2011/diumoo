//
//  musicController.h
//  diumoo
//
//  Created by Shanzi on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mediaSourceBase.h"
#import "musicPlayer.h"



#define PLAYER_STATE_READY (1)
#define SOURCE_STATE_READY (1<<1)

@interface controlCenter : NSObject
{
    musicPlayer* player;
    mediaSourceBase* source;
    NSDictionary* current;
    NSLock* lock;
    NSInteger state;
}


-(BOOL) setPlayer:(musicPlayer*) player;
-(BOOL) setSource:(mediaSourceBase*) source;
-(id) getPlayer;
-(id) getSource;


-(BOOL) _start_to_play;
-(BOOL) play_pause;
-(BOOL) play;
-(BOOL) pause;
-(BOOL) skip;
-(BOOL) rate;
-(BOOL) unrate;
-(BOOL) bye;
-(BOOL) changeChannelTo:(NSInteger) channel;

@end
