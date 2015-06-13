//
//  Destination.m
//  ClickDeliveryTest
//
//  Created by Jaime López on 12/06/15.
//  Copyright (c) 2015 Jaime López. All rights reserved.
//

#import "Destination.h"

@implementation Destination

-(id)initWithDictionary:(NSDictionary *)dictionary andMarker:(GMSMarker *)marker {
    if(!self) {
        self = [[Destination alloc] init];
    }
    
    self.marker = marker;
    
    self.title = [dictionary valueForKey:@"name"];
    self.descr = [[[dictionary valueForKey:@"weather"]objectAtIndex:0] valueForKey:@"description"];
    NSString *firstCapChar = [[self.descr substringToIndex:1] capitalizedString];
    self.descr = [self.descr stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
    self.temp = [[[dictionary valueForKey:@"main"] valueForKey:@"temp"] floatValue];
    self.pressure = [[[dictionary valueForKey:@"main"] valueForKey:@"pressure"] floatValue];
    self.clouds = [[[dictionary valueForKey:@"clouds"] valueForKey:@"all"] floatValue];
    self.humidity = [[[dictionary valueForKey:@"main"] valueForKey:@"humidity"] floatValue];
    self.windSpeed = [[[dictionary valueForKey:@"wind"] valueForKey:@"speed"] floatValue];
    
    return self;
}

@end

