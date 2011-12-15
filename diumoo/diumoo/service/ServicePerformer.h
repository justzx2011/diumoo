//
//  ServicePerformer.h
//  diumoo
//
//  Created by Shanzi on 11-12-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServicePerformer : NSObject
{
    NSPasteboard* defualtPasteboard;
    NSDictionary* allowedService;
}

-(void) performServiceByName:(NSString* ) name withContentString:(NSString*) content;

@end
