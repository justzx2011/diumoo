//
//  musicPlayer.h
//  diumoo
//
//  Created by Shanzi on 11-12-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

#define CHANGE_VOLUME_DURATION 0.8
#define CHANGE_VOLUME_INTERVAL 0.1

@interface musicPlayer : QTMovie
{
    float _volume;
    NSLock* lock;
}

-(void) changeVolumeTo:(NSNumber*)v;
-(void) resumeVolume;
@end
