//
//  main.m
//  diumoo
//
//  Created by Shanzi on 11-12-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "diumooApp.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    [diumooApp sharedApplication];
    NSWorkspace *space = [NSWorkspace sharedWorkspace];
    NSArray *runingAPPs = [space runningApplications];
    int i = 0;
    for (NSRunningApplication *apps in runingAPPs) {
        if ([apps.localizedName isEqualToString:@"diumoo"]) {
            i++;
        }
        if (i>1) {
            
            NSRunCriticalAlertPanel(@"Diumoo 已经在运行了", @"发现您已经运行着 Dimoo 了", @"好", nil, nil);
            
            [[diumooApp sharedApplication] terminate:nil];
        }
    }
    [NSBundle loadNibNamed:@"MainMenu" owner:NSApp];
    [NSApp run];
    [pool drain];
    return 0;
}
