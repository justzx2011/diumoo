//
//  SZMTButton.h
//  SZTestViewAndMultiTouch
//
//  Created by Shanzi on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SZMTButton : NSButton
{
    float value;
    float maxvalue;
    float minvalue;
    float step;
    
    NSImage *image;
    NSColor *arccolor;
    CGFloat arcwidthfactor;
    CGFloat arcradiusfactor;
    
}


@property(retain) NSImage* image;
@property(retain) NSColor* arccolor;
@property(atomic) float value;
@property(atomic) float maxvalue;
@property(atomic) float minvalue;
@property(atomic) float step;
@property(atomic) CGFloat arcwidthfactor;
@property(atomic) CGFloat arcradiusfactor;



- (void) useDefault;

@end
