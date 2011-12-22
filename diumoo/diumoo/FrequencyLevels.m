/*

File: FrequencyLevelsLayer.m

Abstract: Container that creates and handles the frequency levels 

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Inc. 
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2007 Apple Inc. All Rights Reserved.

*/ 

#import "FrequencyLevels.h"

#define LEVEL_OFFSET		8
#define LEVEL_WIDTH		30
#define LEVEL_HEIGHT		200

static UInt32 numberOfBandLevels    = 32;       // increase this number for more frequency bands
static UInt32 numberOfChannels       = 1;       // for StereoMix - If using DeviceMix, you need to get the channel count of the device.

@interface FrequencyLevels (internal)
    - (void)levelTimerMethod:(NSTimer*)theTimer;
@end

@implementation FrequencyLevels

//--------------------------------------------------------------------------------------------------

+ (FrequencyLevels*)levelsWithMovie:(QTMovie *)movie
{
    FrequencyLevels	*levels;

    levels = [[FrequencyLevels alloc] init];
    
    [levels setMovie:movie];
    
    return [levels autorelease];
}

//--------------------------------------------------------------------------------------------------

- (id)init
{

    self = [super init];
	
    // allocate memory for the QTAudioFrequencyLevels struct and set it up
    // depending on the number of channels and frequency bands you want    
    mFreqResults = malloc(offsetof(QTAudioFrequencyLevels, level[numberOfBandLevels * numberOfChannels]));

    mFreqResults->numChannels = numberOfChannels;
    mFreqResults->numFrequencyBands = numberOfBandLevels;
    
    // create an array and load up the UI elements, each NSLevelIndicator has
    // the appropriate tag added in IB
    condition=[[NSCondition alloc] init];
    values=(Float32*) malloc(numberOfChannels*numberOfBandLevels*sizeof(Float32));

    // load image for the level indicator layers

    // create the layers
    mContainer = [[CALayer layer] retain];
    [mContainer setFrame:CGRectMake (0, 0, 1280,200)];
    [mContainer setDelegate:self];

    return self;
}

//--------------------------------------------------------------------------------------------------

- (void)dealloc
{
    // cleanup
    
    [mContainer release];
    
    
    free(mFreqResults);
    free(values);
    
    [super dealloc];
}

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------

- (void)invalidate
{
    if ([[mMovie attributeForKey:QTMovieHasAudioAttribute] boolValue]) 
    {
        // do this once per movie to establish metering
        (void)SetMovieAudioFrequencyMeteringNumBands([mMovie quickTimeMovie], kQTAudioMeter_StereoMix, &numberOfBandLevels);
    }
}

//--------------------------------------------------------------------------------------------------

- (void)setMovie:(QTMovie *)inMovie
{
    mMovie = inMovie;
    if (mMovie)
    {
        [self invalidate];
        
        [mContainer setNeedsDisplay];
    }
}

//--------------------------------------------------------------------------------------------------

- (CALayer*)layer
{
    return mContainer;
}

//--------------------------------------------------------------------------------------------------

// called when the button is pressed - turns the level meters on/off by setting up a timer
- (void)toggleFreqLevels:(NSCellStateValue)state
{
    if (NSOnState == state) 
    {
    	// turning it on, set up a timer and add it to the run loop
        mTimer = [NSTimer timerWithTimeInterval:1.0/15 target:self selector:@selector(levelTimerMethod:) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:mTimer forMode:(NSString *)kCFRunLoopCommonModes];
		mContainer.hidden = NO;
    } 
    else 
    {
        // turning it off, stop the timer and hide the level layers
        [mTimer invalidate];
        mContainer.hidden = YES;
    }
}


//--------------------------------------------------------------------------------------------------

- (void)levelTimerMethod:(NSTimer*)theTimer
{
    UInt8 i, j;
    
    // get the levels from the movie
    OSStatus err = GetMovieAudioFrequencyLevels([mMovie quickTimeMovie], kQTAudioMeter_StereoMix, mFreqResults);
    if (!err) 
    {
        // iterate though the frequency level array and though the UI elements getting
        // and setting the levels appropriately
        for (i = 0; i < mFreqResults->numChannels; i++) 
        {
            for (j = 0; j < mFreqResults->numFrequencyBands; j++) 
            {
                // the frequency levels are Float32 values between 0. and 1.
                Float32 value = (mFreqResults->level[(i * mFreqResults->numFrequencyBands) + j]) * LEVEL_HEIGHT;
                *(values+i*mFreqResults->numChannels + j)=value;
                [mContainer setNeedsDisplay];
            }
        }
    }
}

-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, CGColorCreateGenericRGB(0, 0.5, 1.0, 1.0));
    CGContextMoveToPoint(ctx, 0, 0);
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddCurveToPoint(path, NULL, 0, 0,20,0,40,*(values+0)/2);
    CGPathAddCurveToPoint(path, NULL, 40,*(values+0)/2,60,*(values+0),80,(*(values)+*(values+1))/2);
    int i=1;
    for (; i<numberOfChannels*numberOfBandLevels-1; i++) {
        //NSLog(@"%f",*(values+i));
        CGPathAddCurveToPoint(path, NULL, i*40+40, (*(values+i)+*(values+i-1))/2 , i*40+60, *(values+i), i*40+80,(*(values+i)+*(values+i+1))/2);
    }
    i++;
    CGPathAddCurveToPoint(path, NULL, i*40+40, (*(values+i)+*(values+i-1))/2, i*40+60, *(values+i), i*40+80, *(values+i)/2);
    CGPathAddCurveToPoint(path, NULL, i*40+80, *(values+i)/2, i*40+100, 0, i*40+120, 0);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
}

@end
