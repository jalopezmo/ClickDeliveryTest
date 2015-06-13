//
//  ViewController.m
//  ClickDeliveryTest
//
//  Created by Jaime López on 12/06/15.
//  Copyright (c) 2015 Jaime López. All rights reserved.
//

#import "ViewController.h"
#import "Destination.h"
#import "CustomInfowindow.h"
#import "ListViewController.h"

@interface ViewController ()
@property (nonatomic,strong) NSMutableArray* results;
@property (strong, nonatomic) CLLocation *firstLocation;
@property (strong, nonatomic) NSMutableArray *destinations;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Initialize google map view
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:4.609
                                                            longitude:-74.076
                                                                 zoom:6];
    [self.mapView animateToLocation:camera.target];
    [self.mapView animateToZoom:camera.zoom];
    
    //Initialize first location
    self.firstLocation = nil;
    
    //Set map view delegate to self in order to handle when the mapview is clicked
    [self.mapView setDelegate:self];
    
    //Initialize the marker array
    self.destinations = [[NSMutableArray alloc] init];
    
    //Initialize the location manager and set delegate to self
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    [_locationManager requestAlwaysAuthorization];
    
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter=kCLDistanceFilterNone;
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startMonitoringSignificantLocationChanges];
    [_locationManager startUpdatingLocation];
    
    //Initialize http asynch getter and result array
    self.jsonGet = [[JSONGet alloc] init];
    self.results = [NSMutableArray array];
    self.jsonGet.delegate = self;
    
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
    
    [self.mapView animateToLocation:camera.target];
    [self.mapView animateToZoom:camera.zoom];
    
    //Get the temperature for the new location and add a marker there.
    [self.jsonGet getJSONAsynch:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric&lang=es",location.coordinate.latitude,location.coordinate.longitude]];
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
        //The coord dictionary will have the lat and lon keys, this is in order to put a new marker in the map
        NSDictionary *coord = [jsonDict objectForKey:@"coord"];
        
        //Since the google maps SDK only allows calls from the main thread, we execute the rest there
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //We create a marker in the correct location with the name the service gives us for the location and its temperature.
            GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake([[coord objectForKey:@"lat"] floatValue], [[coord objectForKey:@"lon"] floatValue])];
            
            marker.title = [jsonDict objectForKey:@"name"];
            marker.icon = [UIImage imageNamed:@"pin"];
            marker.map = self.mapView;
            
            Destination *destination = [[Destination alloc] initWithDictionary:jsonDict andMarker:marker];
            
            destination.marker.snippet = destination.descr;
            
            [self.mapView setSelectedMarker:marker];
            
            //Here we add the marker to the marker array for future comparison purposes.
            [self.destinations addObject:destination];
        }];
    }
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    for(Destination *destination in self.destinations) {
        //This object will represent the marker's position
        CLLocation *mPosition = [[CLLocation alloc] initWithLatitude:destination.marker.position.latitude longitude:destination.marker.position.longitude];
        
        //This object will represent position where the user clicked
        CLLocation *cPosition = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        if([mPosition distanceFromLocation:cPosition]/1000 < 20) {
            //If the point where the map was clicked is relatively close to any other point, do not search this point's temperature.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"¡Aún estás muy cerca!" message:@"Diste click en un lugar cercano a donde ya conoces el clima, intenta de nuevo un poco más lejos." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
            [alert show];
            
            return;
        }
    }
    
    //If the point where the user clicked is not near any other point, we look up fot that point's temperature.
    [self.jsonGet getJSONAsynch:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric&lang=es",coordinate.latitude,coordinate.longitude]];
}

-(UIView*) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CustomInfowindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    
    infoWindow.title.text = marker.title;
    infoWindow.descr.text = marker.snippet;
    
    return infoWindow;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    for (int i = 0; i < self.destinations.count; i++) {
        Destination *current = [self.destinations objectAtIndex:i];
        
        if(current.marker == marker) {
            marker.map = nil;
            [self.destinations removeObjectAtIndex:i];
            return;
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"destinations"]) {
        ListViewController *controller = (ListViewController *)segue.destinationViewController;
        controller.destinations = self.destinations;
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"destinations"]) {
        if(self.destinations.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Elige algún destino" message:@"Antes de poder filtrar tus destinos, tienes que escoger por lo menos uno." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else {
            return YES;
        }
    }
    
    return YES;
}

@end
