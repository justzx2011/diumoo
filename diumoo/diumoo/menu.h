//
//  menu.h
//  diumoo
//
//  Created by Shanzi on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ICON_WIDTH 32
#define ALBUM_VIEW_WIDTH 200
#define IMAGE_VIEW_MARGIN 20

@interface menu : NSObject
{
    NSStatusItem * item;
    NSMenu * mainMenu;
    
    NSMenuItem* controlItem;
    NSView * controlView;
    
    NSButton * back;
    NSButton * play_pause;
    NSButton * next;
    NSButton * rate;
    NSButton * bye;
    
    NSImage * play;
    NSImage * pause;
    NSImage * unrate;
    NSImage * rated;
    
    NSImage * play_alt;
    NSImage * pause_alt;
    
    
    NSMenuItem * albumItem;
    NSImageView * albumView;
    NSMenuItem * album_artist;
    NSMenuItem * title;
    NSMenuItem * perfsItem;
    NSMenuItem * aboutItem;
    NSMenuItem * exit;
    
    NSCondition* condition;
    NSMenuItem* current;
    
    id controller;
}


-(void) setController:(id) c;
-(void) reformMenuWithChannels:(NSArray*)channels andCans: (NSSet*) cans;
-(void) _reform:(NSNotification*) noti;

-(void) _build_channel_menu:(NSArray*) dic with: (NSMenu*) menu andTabLength:(NSInteger) n;

-(void) backDetail:(NSNotification*) n;
-(void) setDetail:(NSNotification*) n;
-(void) rateChanged:(NSNotification*)n;

-(IBAction)exitApp:(id)sender;
-(void) backChannel:(NSNumber*) c;
-(IBAction)channelAction:(id)sender;
-(IBAction)buttonAction:(id)sender;
@end
