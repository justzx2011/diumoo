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
    [NSBundle loadNibNamed:@"MainMenu" owner:NSApp];
    [NSApp run];
    [pool drain];
    [pool release];
    return 0;
}
