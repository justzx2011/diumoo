//
//  SZMTButton.m
//  SZTestViewAndMultiTouch
//
//  Created by Shanzi on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SZMTButton.h"

@implementation SZMTButton

@synthesize image,arccolor,value,maxvalue,minvalue,step,arcwidthfactor,arcradiusfactor;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}



- (void) _setvalue:(float)v
{
    if(v > (maxvalue-0.001)) self.value = maxvalue;
    else if (v < (minvalue+ 0.001)) self.value = minvalue;
    else self.value = v;
}

- (void) _togglevalueWithClockWise: (BOOL) clockwise
{
    if(clockwise){
        if(value==maxvalue) [self setValue:minvalue];
        else [self _setvalue: value + step];
    }
    else {
        if(value==minvalue) [self setValue:maxvalue];
        else [self _setvalue:value - step];
    }
}

- (void) useDefault
{
    self.arccolor = [NSColor colorWithCalibratedRed:6.0f/16.0f green:12.0f/16.0f blue:1.0f alpha:1.0f];
    self.arcwidthfactor=0.2;
    self.arcradiusfactor=0.9;
    self.value=1.0;
    self.maxvalue=1.0;
    self.minvalue=0.0;
    self.step=0.2;
}



- (void)drawRect:(NSRect)dirtyRect
{

    // Get radius,center,origin
    CGFloat width = dirtyRect.size.width;
    CGFloat height = dirtyRect.size.height;
    
    CGFloat radius = (width > height) ? height / 2.00 : width / 2.00;
    
    [NSGraphicsContext saveGraphicsState];
    
    if (self.image) {
        // get proper position for image
        CGFloat imgwidth = image.size.width;
        CGFloat imgheight = image.size.height;
        CGFloat imgd = imgwidth>imgheight ? imgwidth : imgheight;
        CGFloat fractor = (radius*2.0)/imgd;
        
        
        NSRect imgrect = NSMakeRect((width - imgwidth*fractor)*0.5 , (height - imgheight*fractor)*0.5,imgwidth*fractor,imgheight*fractor);
        [image setFlipped:YES];
        [image drawInRect:imgrect fromRect:NSMakeRect(0, 0, imgwidth, imgheight) operation:NSCompositeSourceOver fraction:1.0]; // draw image
    }
    

        // --------------------------
        // draw arc
        [arccolor setStroke]; // set stroke of arc
        NSPoint origin = NSMakePoint(width/2, height/2); // get origin
        CGFloat arcwidth = radius * arcwidthfactor;
        CGFloat arcradius = radius * arcradiusfactor;
        NSBezierPath * path = [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:origin radius:arcradius startAngle:0.0f endAngle:360.0 * value ];
        [path setLineWidth:arcwidth];
        [path setLineCapStyle:NSRoundLineCapStyle];
        [path stroke];  // stroke arc
        
        [NSGraphicsContext restoreGraphicsState];
    
}


- (BOOL) acceptsFirstResponder
{
    return YES;
}



- (void) mouseDown:(NSEvent *)event
{
    [self _togglevalueWithClockWise:NO];
    [self setNeedsDisplay];
}


- (void) rightMouseDown:(NSEvent *)event
{
    [self _togglevalueWithClockWise:YES];
    [self setNeedsDisplay];
}

- (void) viewDidEndLiveResize
{
    [self setNeedsDisplay];  //refresh view after resize
}


- (void) magnifyWithEvent:(NSEvent *)event
{
    [self _setvalue:value + [event magnification] * (maxvalue-minvalue)];
    [self setNeedsDisplay];
}

- (void) scrollWheel:(NSEvent *)event
{
    [self _setvalue: value - [event scrollingDeltaY]/100.0*(maxvalue - minvalue)];
    [self setNeedsDisplay];
}


@end
