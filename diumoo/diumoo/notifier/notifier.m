//
//  growlNotifier.m
//  diumoo
//
//  Created by Shanzi on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "notifier.h"

@implementation notifier

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [GrowlApplicationBridge setGrowlDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify:) name:@"player.startToPlay" object:nil];
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

-(void) notify:(NSNotification*)noti
{
    [self growlNotification:noti.userInfo withImage:noti.object];
    [self iTunesNotification:noti.userInfo];
    
}

-(void) growlNotification:(NSDictionary*)user_info withImage:(id)img
{
    if(!([GrowlApplicationBridge isGrowlRunning]))return;
    NSString* d=[NSString stringWithFormat:@"\n%@ - %@ \n< %@ > %@",[user_info valueForKey:@"Name"],[user_info valueForKey:@"Artist"],[user_info valueForKey:@"Album"],
                 [user_info valueForKey:@"Year"]];
    NSData* image=nil;
    if(img!=nil && [img respondsToSelector:@selector(TIFFRepresentation)])
        image=[img TIFFRepresentation];
    if(image==nil) image=[[NSImage imageNamed:@"album.png"] TIFFRepresentation];
    [GrowlApplicationBridge notifyWithTitle:@"Now Playing" description:d notificationName:@"New Song" iconData:image priority:0 isSticky:NO clickContext:nil];
}

-(void) iTunesNotification:(NSDictionary*)noti
{
    NSMutableDictionary* dic=[[NSMutableDictionary alloc] init];
    [dic setValuesForKeysWithDictionary:noti];
    NSString * name=[dic valueForKey:@"Name"];
    [dic setValue:[NSString stringWithFormat:@"%@ - %@",name,[dic valueForKey:@"Artist"]] forKey:@"Name"];
    
    [dic setValue:@"Playing" forKey:@"Player State"];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" userInfo:dic];
}


@end
