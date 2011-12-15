//
//  menu.h
//  diumoo
//
//  Created by Shanzi on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "controlCenter.h"

#define ICON_WIDTH 32
#define ALBUM_VIEW_WIDTH 200
#define IMAGE_VIEW_MARGIN 20

@interface menu : NSObject
{
    NSStatusItem * item;
    NSMenu * mainMenu;
    
    NSMenuItem* controlItem;
    NSView * controlView;
    
    NSButton * play_pause;
    NSButton * next;
    NSButton * rate;
    NSButton * bye;
    
    NSImage * play;
    NSImage * pause;
    NSImage * unlike;
    NSImage * like;
    
    NSImage * play_alt;
    NSImage * pause_alt;
    
    
    NSMenuItem * albumItem;
    NSImageView * albumView;
    NSMenuItem * artist;
    NSMenuItem * album;
    NSMenuItem * title;
    NSMenuItem * perfsItem;
    NSMenuItem * aboutItem;
    NSMenuItem * exit;
    
    NSCondition* condition;
    NSMenuItem* current;
    
    controlCenter* controller;
}


-(void) setController:(id) c;
-(void) reformMenuWithSourceName:(NSString*) name channels:(NSArray*)channels andCans: (NSSet*) cans;
-(void) _reform:(NSNotification*) noti;

-(void) _build_channel_menu:(NSArray*) dic with: (NSMenu*) menu andTabLength:(NSInteger) n;

-(void) setDetail:(NSNotification*) n;
-(void) rateChanged:(NSNotification*)n;

-(IBAction)exitApp:(id)sender;
-(void) backChannelTo:(NSNumber*) c;
-(IBAction)channelAction:(id)sender;
-(IBAction)buttonAction:(id)sender;

-(void) enablesNotification:(NSNotification*)n;
@end
