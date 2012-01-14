//
//  diumooApp.m
//  diumoo
//
//  Created by Shanzi on 11-12-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "diumooApp.h"
#import "SPMediaKeyTap.h"


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
    BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
    if(shouldHandleMediaKeyEventLocally && [event type] == NSSystemDefined && [event subtype] == 8 )
    {
        [(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:event];
    }
    [super sendEvent:event];
}


@end
