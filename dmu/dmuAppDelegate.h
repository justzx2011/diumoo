//
//  dmuAppDelegate.h
//  dmu
//
//  Created by Shanzi on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindow.h"


@interface dmuAppDelegate : NSObject <NSApplicationDelegate> {

    IBOutlet NSMenu* mainMenu;
    IBOutlet NSMenu* public_fm;
    IBOutlet NSMenu* dj_fm;
    NSMenuItem* current_channel;
    
    IBOutlet NSWindow* account;
    IBOutlet NSTextField* username;
    IBOutlet NSSecureTextField* password;
    IBOutlet MainWindow* window;
    NSStatusItem* statusItem;

}
@property (nonatomic,retain) IBOutlet MainWindow* window;
@property (nonatomic,retain) IBOutlet NSWindow* account;
@property(nonatomic,retain) NSMenu* mainMenu;
@property(nonatomic,retain) NSMenu* public_fm;
@property(nonatomic,retain) NSMenu* dj_fm;
@property(nonatomic,retain) NSTextField* username;
@property(nonatomic,retain) NSSecureTextField* password;


- (void)applicationDidBecomeActive:(NSNotification *)notification;
-(void)applicationDidResignActive:(NSNotification *)notification;


-(IBAction)exit:(id)sender;
-(IBAction)showOrHideQuickbox:(id)sender;
-(IBAction)pinQuickbox:(id)sender;

-(IBAction)_channel:(id)sender;

-(IBAction)showDoubanAccountWindow:(id)sender;
-(IBAction)setDoubanAccount:(id)sender;





@end
