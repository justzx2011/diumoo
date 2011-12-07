//
//  musicPlayer.m
//  diumoo
//
//  Created by Shanzi on 11-12-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "musicPlayer.h"

@implementation musicPlayer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _volume=1.0;
        [self setVolume:_volume];
        lock=[[NSLock alloc] init];
    }
    
    return self;
}
-(void) changeVolumeTo:(NSNumber *)v
{
    float vo=[v floatValue];
    float vn=self.volume;
    if([lock tryLock])
        for (float f=0; f<=CHANGE_VOLUME_DURATION; f+= CHANGE_VOLUME_INTERVAL) {
            [super setVolume: vn+(vo-vn)*f/CHANGE_VOLUME_DURATION];
            [NSThread sleepForTimeInterval:CHANGE_VOLUME_DURATION];
        }
}
-(void) resumeVolume
{
    [self performSelectorInBackground:@selector(changeVolumeTo:) withObject:[NSNumber numberWithFloat:_volume]];
}

-(void) setVolume:(float)volume
{
    [self performSelectorInBackground:@selector(changeVolumeTo:) withObject:[NSNumber numberWithFloat:volume]];
    _volume=volume;

}
-(void) 

@end
