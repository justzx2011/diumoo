//
//  musicPlayer.h
//  diumoo
//
//  Created by Shanzi on 11-12-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

@interface musicPlayer : NSObject
{
    QTMovie* player;
    NSDictionary* current_music;
    NSCondition* condition;
}

-(void) startToPlay:(NSDictionary*) music;

-(void) play;
-(void) pause;

-(float) volume;
-(void) setVolume:(float) v;

@end
