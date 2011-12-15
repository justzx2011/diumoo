//
//  ServicePerformer.m
//  diumoo
//
//  Created by Shanzi on 11-12-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ServicePerformer.h"

@implementation ServicePerformer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        defualtPasteboard =[NSPasteboard pasteboardWithName:@"diumoo_service_pasteboard"];
        allowedService=[NSDictionary dictionaryWithObjectsAndKeys:@"Tweet",@"Tweet",@"Search With Google",@"Google", nil];
    }
    
    return self;
}

-(void) performServiceByName:(NSString *)name withContentString:(NSString *)content
{
    if([allowedService valueForKey:name]!=nil)
        [defualtPasteboard setString:content forType:NSStringPboardType],
        NSPerformService(@"Tweet", defualtPasteboard);
}

@end
