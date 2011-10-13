//
//  dmuAppDelegate.h
//  dmu
//
//  Created by Shanzi on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FmController.h"
#import "MainWindow.h"


@interface dmuAppDelegate : NSObject <NSApplicationDelegate> {

    MainWindow* window;
}
@property (nonatomic,retain) IBOutlet MainWindow* window;




@end
