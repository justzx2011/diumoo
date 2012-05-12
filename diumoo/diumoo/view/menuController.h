//
//  menuController.h
//  diumoo
//
//  Created by Zheng Anakin on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "controlCenter.h"
#import "preference.h"
#import "SZMTButton.h"

#define ICON_WIDTH 32
#define ALBUM_VIEW_WIDTH 200
#define IMAGE_VIEW_MARGIN 20

@interface menuController : NSViewController
{
    NSStatusItem* statusItem;
    
    NSMenu* mainMenu;
    NSMenuItem* current;
    NSMenuItem* albumItem;
    NSMenuItem* heartChannel;
    NSMenuItem* privateChannel;
    NSMenuItem* defaultChannel;
    NSMenuItem* lastChannel;
    NSMenuItem* prefsItem;
    NSMenuItem* aboutItem;
    NSMenuItem* exit;
    
    IBOutlet NSButton* play_pause;
    IBOutlet NSButton* next;
    IBOutlet NSButton* like;
    IBOutlet NSButton* bye;
    IBOutlet NSImageView* album_img;
    IBOutlet NSTextField* album;
    IBOutlet NSTextField* artist;
    IBOutlet NSTextField* music;
    IBOutlet NSTextField* year;
    IBOutlet NSButton* star;
    IBOutlet NSTextField * rate_text;
    IBOutlet NSButton* account;
    IBOutlet NSTextField* account_name;
    
    SZMTButton * volume;
    
    NSCondition* condition;
    NSString* url;
    BOOL firstDetail;
    id target;
    
    SEL selector;

}

-(void) reformMenuWithSourceName:(NSString*) name channels:(NSArray*)channels andCans: (NSSet*) cans;
-(void) _reform:(NSNotification*) noti;
-(void) _build_channel_menu:(NSArray*) dic with: (NSMenu*) menu andTabLength:(NSInteger) n;
-(void) setDetail:(NSNotification*) n;
-(void) rateChanged:(NSNotification*)n;
-(IBAction)exitApp:(id)sender;
-(void) backChannelTo:(NSNumber*) c;
-(IBAction)channelAction:(id)sender;
-(void)_channel_action:(id)sender;
-(IBAction)buttonAction:(id)sender;
-(IBAction)showPrefs:(id)sender;

-(void) fireToPlayTheDefaultChannel;
-(BOOL) lightHeart;
-(void) enablesNotification:(NSNotification*)n;
-(void) setDetail:(NSDictionary*) music withImage:(NSImage*) image;
-(void) setServiceTarget:(id)target withSelector:(SEL) s;
-(void) setAccountDetail:(NSNotification*)n;

-(IBAction)showAccount:(id)sender;

-(IBAction)serviceCallback:(id)sender;

@end
