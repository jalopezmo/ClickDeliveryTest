//
//  JSONGet.h
//  PruebaCima
//
//  Created by Jaime López on 25/05/15.
//  Copyright (c) 2015 Jaime López. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONDelegate.h"

@protocol JSONDelegate;

@interface JSONGet : NSObject

@property (weak, nonatomic) id<JSONDelegate> delegate;

-(void) getJSONAsynch: (NSString*) url;

@end
