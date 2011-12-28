//
//  diumooApp.m
//  diumoo
//
//  Created by Shanzi on 11-12-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "diumooApp.h"
#import "controlCenter.h"
#import <IOKit/hidsystem/ev_keymap.h>


@implementation diumooApp

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        
    }
    
    return self;
}

-(void) sendEvent:(NSEvent *)event
{
    if( [event type] == NSSystemDefined && [event subtype] == 8 )
    {
        NSLog(@"%d",[event data1]);
        NSLog(@"%d",[event data1]& 0x0000FFFF);
        int keyCode = (([event data1] & 0xFFFF0000) >> 16);
        int keyFlags = ([event data1] & 0x0000FFFF);
		int keyState = (((keyFlags & 0xFF00) >> 8)) ==0xA;
        if(keyState==0 &&  ([event modifierFlags] & NSShiftKeyMask) && ([event modifierFlags] & NSCommandKeyMask))
            switch (keyCode) {
                case NX_KEYTYPE_PLAY:
                    if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"PlayPauseFastHotKey"] integerValue]==NSOnState)
                    [[controlCenter sharedCenter] play_pause];
                    break;
                case NX_KEYTYPE_FAST:
                case NX_KEYTYPE_NEXT:
                    if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"PlayPauseFastHotKey"] integerValue]==NSOnState)
                        [[controlCenter sharedCenter] skip];
                    break;
                case NX_KEYTYPE_REWIND:
                case NX_KEYTYPE_PREVIOUS:
                    if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"RateHotKey"] integerValue]==NSOnState)
                        [[controlCenter sharedCenter] rate];
                    break;
            }
    }
    [super sendEvent:event];
}


@end
