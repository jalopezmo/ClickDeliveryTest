//
//  JSONGet.m
//  PruebaCima
//
//  Created by Jaime López on 25/05/15.
//  Copyright (c) 2015 Jaime López. All rights reserved.
//

#import "JSONGet.h"

@implementation JSONGet

-(void)getJSONAsynch: (NSString*) url {
    NSURL *getURL = [[NSURL alloc] initWithString:url];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:getURL] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.delegate getJSONFailedWithError: error];
        } else {
            [self.delegate didReceiveJSON: data];
        }
    }];
}

@end
