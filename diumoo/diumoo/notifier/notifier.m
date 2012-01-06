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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyAccount:) name:@"source.account" object:nil];
    }
    
    return self;
}
-(NSDictionary*) registrationDictionaryForGrowl{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray arrayWithObjects:@"New Song",@"Account", nil],
            GROWL_NOTIFICATIONS_ALL,
            [NSArray arrayWithObjects:@"New Song",@"Account", nil],
            GROWL_NOTIFICATIONS_DEFAULT,
            nil];
}


-(void) notify:(NSNotification*)noti
{
    [self growlNotification:noti.userInfo withImage:noti.object];
    [self iTunesNotification:noti.userInfo];
    
}

-(void) notifyAccount:(NSNotification *)noti
{
    if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"EnableGrowl"] integerValue]!=NSOnState) return;
    if(!([GrowlApplicationBridge isGrowlRunning]))return;
    if(noti.userInfo!=nil){
        NSDictionary* dic=[noti.userInfo valueForKey:@"play_record"];
        NSString* s=[NSString stringWithFormat:@"Hello %@ !\n\n您的播放记录为:\n\t听过歌曲:%@首\n\t标记红心:%@首\n\t不再播放:%@首\nNow enjoy yourself!",[noti.userInfo valueForKey:@"name"],[dic valueForKey:@"played"],[dic valueForKey:@"liked"],[dic valueForKey:@"banned"]];
        [GrowlApplicationBridge notifyWithTitle:@"登陆成功" description:s notificationName:@"Account" iconData:noti.object priority:0 isSticky:NO clickContext:nil];
    }
    else
    {
        [GrowlApplicationBridge notifyWithTitle:@"账号已登出" description:@"您的账号已经退出登陆或登录失败" notificationName:@"Account" iconData:nil priority:0 isSticky:NO clickContext:nil];
    }
           
}

-(void) growlNotification:(NSDictionary*)user_info withImage:(id)img
{
    if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"EnableGrowl"] integerValue]!=NSOnState) return;
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
    if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"EnableiTunes"] integerValue]!=NSOnState) return;
    NSMutableDictionary* dic=[[NSMutableDictionary alloc] init];
    [dic setValuesForKeysWithDictionary:noti];
    [dic setValue:@"Playing" forKey:@"Player State"];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" userInfo:dic];
    [dic release];
}


@end
