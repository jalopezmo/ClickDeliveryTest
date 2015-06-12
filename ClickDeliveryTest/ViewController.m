//
//  ViewController.m
//  ClickDeliveryTest
//
//  Created by Jaime López on 12/06/15.
//  Copyright (c) 2015 Jaime López. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,strong) NSMutableArray* results;
@property (nonatomic,strong) GMSMapView *mapView;
@property (strong, nonatomic) CLLocation *firstLocation;
@property (strong, nonatomic) NSMutableArray *markers;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Initialize google map view
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:4.609
                                                            longitude:-74.076
                                                                 zoom:6];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = _mapView;
    
    //Initialize first location
    self.firstLocation = nil;
    
    //Set map view delegate to self in order to handle when the mapview is clicked
    _mapView.delegate = self;
    
    //Initialize the marker array
    self.markers = [[NSMutableArray alloc] init];
    
    //Initialize the location manager and set delegate to self
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    [_locationManager requestAlwaysAuthorization];
    
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter=kCLDistanceFilterNone;
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startMonitoringSignificantLocationChanges];
    [_locationManager startUpdatingLocation];
    
    //Show app instructions
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"¡Bienvenido a tus vacaciones!" message:@"Puedes dar click en cualquier lugar para conocer su clima y saber si es el destino ideal para tus vacaciones." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //Get latest location
    CLLocation *location = [locations objectAtIndex:(locations.count - 1)];
    
    //In case the first location is defined, we look if the user has moved enough to make a new request to the service.
    if(self.firstLocation) {
        CLLocationDistance distance = [location distanceFromLocation:self.firstLocation];
        float distanceK = distance/1000;
        
        if(distanceK < 100) {
            //The distance is too short to get a new temperature
            return;
        }
        
        self.firstLocation = location;
    }
    else {
        //In case it is not defined, initialize it
        self.firstLocation = location;
    }
    
    //Move the map to the new location.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                            longitude:location.coordinate.longitude
                                                                 zoom:12];
    
    [_mapView animateToLocation:camera.target];
    [_mapView animateToZoom:camera.zoom];
    
    //Get the temperature for the new location and add a marker there.
    self.jsonGet = [[JSONGet alloc] init];
    self.results = [NSMutableArray array];
    self.jsonGet.delegate = self;
    NSLog(@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric",location.coordinate.latitude,location.coordinate.longitude);
    [self.jsonGet getJSONAsynch:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric",location.coordinate.latitude,location.coordinate.longitude]];
}


- (void)getJSONFailedWithError:(NSError *)error {
    //This method gets called when the asynch task stops running and the service responded an error status
    NSLog(@"%@",[error localizedDescription]);
}

- (void)didReceiveJSON:(NSData *)data {
    //This method gets called when the asynch task stops running and the service responded a non-error status
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error) {
        //This error is in case the JSON serialization runs into any issue.
        NSLog(@"%@",[error localizedDescription]);
        return;
    }
    
    if([jsonDict isKindOfClass:[NSDictionary class]]) {
        //Here we extract the data of interest from the JSON
        
        //The main dictionary will have the temp key, which contains temperature information
        NSDictionary *main = [jsonDict objectForKey:@"main"];
        //The coord dictionary will have the lat and lon keys, this is in order to put a new marker in the map
        NSDictionary *coord = [jsonDict objectForKey:@"coord"];
        
        //Since the google maps SDK only allows calls from the main thread, we execute the rest there
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //We create a marker in the correct location with the name the service gives us for the location and its temperature.
            GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake([[coord objectForKey:@"lat"] floatValue], [[coord objectForKey:@"lon"] floatValue])];
            
            marker.title = [jsonDict objectForKey:@"name"];
            marker.snippet = [NSString stringWithFormat:@"Temperatura: %.02f ºC", [[main valueForKey:@"temp"] floatValue]];
            
            [_mapView setSelectedMarker:marker];
            
            marker.map = _mapView;
            
            //Here we add the marker to the marker array for future comparison purposes.
            [self.markers addObject:marker];
        }];
    }
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    for(GMSMarker *marker in self.markers) {
        //This object will represent the marker's position
        CLLocation *mPosition = [[CLLocation alloc] initWithLatitude:marker.position.latitude longitude:marker.position.longitude];
        
        //This object will represent position where the user clicked
        CLLocation *cPosition = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        if([mPosition distanceFromLocation:cPosition]/1000 < 25) {
            //If the point where the map was clicked is relatively close to any other point, do not search this point's temperature.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"¡Aún estás muy cerca!" message:@"Diste click en un lugar cercano a donde ya conoces el clima, intenta de nuevo un poco más lejos." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
            [alert show];
            
            return;
        }
    }
    
    //If the point where the user clicked is not near any other point, we look up fot that point's temperature.
    [self.jsonGet getJSONAsynch:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric",coordinate.latitude,coordinate.longitude]];
}

@end
