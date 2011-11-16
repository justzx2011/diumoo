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
    IBOutlet MainWindow* window;    
    NSStatusItem* statusItem;


}
@property (nonatomic,retain) IBOutlet MainWindow* window;
@property(nonatomic,retain) NSMenu* mainMenu;

- (void)applicationDidBecomeActive:(NSNotification *)notification;
-(void)applicationDidResignActive:(NSNotification *)notification;


-(IBAction)exit:(id)sender;
-(IBAction)showOrHideQuickbox:(NSMenuItem*)sender;
-(IBAction)pinQuickbox:(id)sender;




@end
