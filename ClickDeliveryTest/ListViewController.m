//
//  ListViewController.m
//  ClickDeliveryTest
//
//  Created by Jaime López on 13/06/15.
//  Copyright (c) 2015 Jaime López. All rights reserved.
//

#import "ListViewController.h"
#import "Destination.h"

@implementation ListViewController

@synthesize destinations = _destinations;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //This is the filter array
    self.properties = @[@"Temperatura más alta",@"Temperatura más baja",@"Humedad más alta", @"Humedad más baja", @"Presión atmosférica más alta",@"Presión atmosférica más baja",@"Velocidad de viento más alta",@"Velocidad de viento más baja",@"Más nublado",@"Menos nublado"];
    
    //This will be the picker assigned to the filter text field
    UIPickerView *propertyPicker = [[UIPickerView alloc]init];
    propertyPicker.dataSource = self;
    propertyPicker.delegate = self;
    
    _propertyText.inputView = propertyPicker;
    
    //We initialize the picker, so that an initial order is set in the list
    _selectedProperty = 0;
    _propertyText.text = [_properties objectAtIndex:0];
    
    //We set the delegate for the table view
    _destinationList.delegate = self;
    _destinationList.dataSource = self;
    
    //We arrange the destinations by the initial filter
    [self arrangeDestinations];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _properties.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_properties objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedProperty = (int)row;
    _propertyText.text = [_properties objectAtIndex:row];
    [[self view] endEditing:YES];
    
    //Update the destination array
    [self arrangeDestinations];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.destinations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //We initialize the table cell
    UITableViewCell *cell;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:@"cell"];
    }
    
    // Set the loaded data to the appropriate cell labels.
    Destination *current = [self.destinations objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", current.title];
    
    //Depending on which filter is selected, we show different information as the cell's subtitle
    switch (_selectedProperty) {
        case 0:
            
        case 1:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Temperatura: %.01f ºC", current.temp];
            break;
        case 2:
            
        case 3:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Humedad: %.01f%%", current.humidity];
            break;
        case 4:
            
        case 5:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Presión: %.01f hPa", current.pressure];
            break;
        case 6:
            
        case 7:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Velocidad del viento: %.01f m/s", current.windSpeed];
            break;
        case 8:
            
        case 9:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Nublado: %.01f%%", current.clouds];
            break;
            
            
        default:
            break;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //We show all the destination's information in an alert view
    Destination *selected = [_destinations objectAtIndex:indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: selected.title message:[NSString stringWithFormat: @"Pronóstico: %@\nTemperatura: %.01f ºC\nPresión: %.01f hPa\nNublado: %.01f %%\nHumedad: %.01f %%\nVelocidad del viento: %.01f m/s",selected.descr,selected.temp,selected.pressure,selected.clouds,selected.humidity,selected.windSpeed] delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
    [alert show];
}

-(void)arrangeDestinations {
    NSArray *sortedArray;
    
    //According to the filter we have selected, the destination array is organized and updated
    if(_selectedProperty == 0) {
        sortedArray = [_destinations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float first = ((Destination*)a).temp;
            float second = ((Destination*)b).temp;
            
            if ( first > second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first < second ) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    else if(_selectedProperty == 1) {
        sortedArray = [_destinations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float first = ((Destination*)a).temp;
            float second = ((Destination*)b).temp;
            
            if ( first < second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first > second ) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    else if(_selectedProperty == 2) {
        sortedArray = [_destinations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float first = ((Destination*)a).humidity;
            float second = ((Destination*)b).humidity;
            
            if ( first > second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first < second ) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    else if(_selectedProperty == 3) {
        sortedArray = [_destinations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float first = ((Destination*)a).humidity;
            float second = ((Destination*)b).humidity;
            
            if ( first < second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first > second ) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    else if(_selectedProperty == 4) {
        sortedArray = [_destinations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float first = ((Destination*)a).pressure;
            float second = ((Destination*)b).pressure;
            
            if ( first > second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first < second ) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    else if(_selectedProperty == 5) {
        sortedArray = [_destinations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float first = ((Destination*)a).pressure;
            float second = ((Destination*)b).pressure;
            
            if ( first < second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first > second ) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    else if(_selectedProperty == 6) {
        sortedArray = [_destinations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float first = ((Destination*)a).windSpeed;
            float second = ((Destination*)b).windSpeed;
            
            if ( first > second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first < second ) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    else if(_selectedProperty == 7) {
        sortedArray = [_destinations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float first = ((Destination*)a).windSpeed;
            float second = ((Destination*)b).windSpeed;
            
            if ( first < second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first > second ) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    else if(_selectedProperty == 8) {
        sortedArray = [_destinations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float first = ((Destination*)a).clouds;
            float second = ((Destination*)b).clouds;
            
            if ( first > second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first < second ) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    else if(_selectedProperty == 9) {
        sortedArray = [_destinations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float first = ((Destination*)a).clouds;
            float second = ((Destination*)b).clouds;
            
            if ( first < second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first > second ) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    
    _destinations = [sortedArray mutableCopy];
    [_destinationList reloadData];
    
    Destination *selected = [_destinations objectAtIndex:0];
    
    //When the array has been organized, we show the user which is his ideal destination.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Encontramos tu destino ideal" message:[NSString stringWithFormat: @"Según tu criterio de %@, tu destino ideal es: %@",[_properties objectAtIndex:_selectedProperty],selected.title] delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
    [alert show];
}

@end
