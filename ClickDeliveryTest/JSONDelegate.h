//
//  JSONDelegate.h
//  PruebaCima
//
//  Created by Jaime López on 25/05/15.
//  Copyright (c) 2015 Jaime López. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONDelegate <NSObject>

- (void)getJSONFailedWithError:(NSError*) error;
- (void)didReceiveJSON: (NSData *) data;

@end
