//
//  TransitViewController.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-09.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataURLConnection.h"


@interface TransitViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

-(IBAction)goBack;


@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UITableView *busTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;


- (IBAction)addBusStop:(id)sender;
- (void)makeRequest:(NSString*)busstop;
@end
