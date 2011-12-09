//
//  musicController.h
//  diumoo
//
//  Created by Shanzi on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define PLAYER_STATE_READY (1)
#define SOURCE_STATE_READY (1<<1)

@interface musicController : NSObject
{
    id player;
    id source;
    NSDictionary* current;
    NSLock* lock;
    
    NSInteger state;
}

-(void) musicEnded;

-(BOOL) setPlayer:(id) player;
-(BOOL) setSource:(id) source;

-(BOOL) _start_to_play;
-(BOOL) play;
-(BOOL) pause;
-(BOOL) skip;
-(BOOL) rate;
-(BOOL) unrate;
-(BOOL) bye;
-(BOOL) changeChannelTo:(NSInteger) channel;

@end
