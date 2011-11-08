//
//  dmuAppDelegate.h
//  dmu
//
//  Created by Shanzi on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindow.h"
#import "Noti.h"


@interface dmuAppDelegate : NSObject <NSApplicationDelegate> {

    IBOutlet MainWindow* window;

}
@property (nonatomic,retain) IBOutlet MainWindow* window;

- (void)applicationDidBecomeActive:(NSNotification *)notification;
-(void)applicationDidResignActive:(NSNotification *)notification;






@end
