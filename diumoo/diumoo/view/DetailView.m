//
//  DetailView.m
//  diumoo
//
//  Created by Shanzi on 11-12-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DetailView.h"

@implementation DetailView

-(id)init
{
    self = [super initWithNibName:@"DetailView.nib" bundle:nil];
    if(self)
    {
        
    }
    return self;
}

-(void) awakeFromNib
{
    [album_img setImage:[NSImage imageNamed:@"album.png"]];
}

-(void) setDetail:(NSDictionary*) info withImage:(NSImage*) image
{
    NSImage* img;
    if(image!=nil)img=image;
    else img=[NSImage imageNamed:@"album.png"];

    
    float scale=250/([image size].width>[image size].height?image.size.width:image.size.height);
    if(scale<1.0)
    {
        [album_img setFrameSize:NSMakeSize(image.size.width*scale, image.size.height*scale)];
        [[self view] setFrameSize:NSMakeSize(300, [album_img frame].size.height + 130)];
    }
    else{
        [album_img setFrameSize:[img size]];
        [[self view]setFrameSize:NSMakeSize(230,[img size].height+130)];
    }
    
    
    
    [album_img setImage:img];
    if([info valueForKey:@"Artist"]!=nil)
        [artist setStringValue:[info valueForKey:@"Artist"]];
    else [artist setStringValue:@"未知艺术家"];
    
    
    if([info valueForKey:@"Year"]!=nil) [year setStringValue:[NSString stringWithFormat:@"%@",[info valueForKey:@"Year"]]];
    else [year setStringValue:@"--"];
    
    if([info valueForKey:@"Album"]!=nil)
        [album setStringValue:[info valueForKey:@"Album"]];
    else [album setStringValue:@"未知唱片集"];
    
    if([info valueForKey:@"Name"]!=nil)
        [music setStringValue:[info valueForKey:@"Name"]];
    else [music setStringValue:@"未知歌曲"];
}

-(void) setServiceTarget:(id)t withSelector:(SEL)s
{
    target=t;
    selector=s;
}

-(IBAction)serviceCallback:(id)sender
{
    if([target respondsToSelector:selector]){
        NSString* s;
        if([sender tag]==0) s=@"twitter";
        else s=@"google";
        
        [target performSelector:selector withObject:s];
    }
        
}

@end
