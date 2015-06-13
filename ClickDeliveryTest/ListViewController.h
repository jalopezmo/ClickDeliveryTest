//
//  ListViewController.h
//  ClickDeliveryTest
//
//  Created by Jaime López on 13/06/15.
//  Copyright (c) 2015 Jaime López. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property int selectedProperty;
@property (nonatomic,strong) NSArray *properties;
@property (nonatomic,strong) NSMutableArray *destinations;

@property (strong, nonatomic) IBOutlet UITextField *propertyText;
@property (strong, nonatomic) IBOutlet UITableView *destinationList;

@end
