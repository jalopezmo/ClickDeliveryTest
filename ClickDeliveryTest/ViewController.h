//
//  ViewController.h
//  ClickDeliveryTest
//
//  Created by Jaime López on 12/06/15.
//  Copyright (c) 2015 Jaime López. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "JSONDelegate.h"
#import "JSONGet.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate, JSONDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) JSONGet *jsonGet;

@end

