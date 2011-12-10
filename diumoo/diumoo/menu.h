//
//  menu.h
//  diumoo
//
//  Created by Shanzi on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface menu : NSObject
{
    NSStatusItem * item;
    NSMenu * mainMenu;
    NSView * controlView;
    NSMenuItem * albumItem;
    NSImageView * albumView;
    NSMenuItem * perfsItem;
    NSMenuItem * aboutItem;
    NSMenuItem * exit;
}
@end
