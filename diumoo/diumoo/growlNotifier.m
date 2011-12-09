//
//  growlNotifier.m
//  diumoo
//
//  Created by Shanzi on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "growlNotifier.h"

@implementation growlNotifier

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [GrowlApplicationBridge setGrowlDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(growlNotification:) name:@"player.startToPlay" object:nil];
    }
    
    return self;
}
-(NSDictionary*) registrationDictionaryForGrowl{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray arrayWithObjects:@"New Song",@"Rate A Song", nil],
            GROWL_NOTIFICATIONS_ALL,
            [NSArray arrayWithObjects:@"New Song",@"Rate A Song", nil],
            GROWL_NOTIFICATIONS_DEFAULT,
            nil];
}

-(void) growlNotification:(NSNotification *)noti
{
    NSLog(@">>>>Noitification!!!");
    if(!([GrowlApplicationBridge isGrowlRunning]))return;
    NSDictionary* user_info=[noti userInfo];
    NSString* d=[NSString stringWithFormat:@"\n%@ - %@ \n< %@ > %@",[user_info valueForKey:@"Title"],[user_info valueForKey:@"Artist"],[user_info valueForKey:@"Album"],
                 [user_info valueForKey:@"Year"]];
    NSData* image=nil;
    if([noti object]&& [[noti object] respondsToSelector:@selector(TIFFRepresentation)])
        image=[[noti object] TIFFRepresentation];
    [GrowlApplicationBridge notifyWithTitle:@"Now Playing" description:d notificationName:@"New Song" iconData:image priority:0 isSticky:NO clickContext:nil];
}

@end
