//
//  Destination.h
//  ClickDeliveryTest
//
//  Created by Jaime López on 12/06/15.
//  Copyright (c) 2015 Jaime López. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface Destination : NSObject

@property (nonatomic, strong) GMSMarker *marker;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *descr;
@property float temp;
@property float pressure;
@property float clouds;
@property float humidity;
@property float windSpeed;

-(id)initWithDictionary:(NSDictionary*)dictionary andMarker:(GMSMarker*)marker;

@end
