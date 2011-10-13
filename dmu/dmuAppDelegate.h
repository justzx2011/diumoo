//
//  dmuAppDelegate.h
//  dmu
//
//  Created by Shanzi on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FmController.h"


@interface dmuAppDelegate : NSObject <NSApplicationDelegate> {

    NSWindow* window;
}
@property (nonatomic,retain) IBOutlet NSWindow* window;




@end
