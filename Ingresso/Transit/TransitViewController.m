//
//  TransitViewController.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-09.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "TransitViewController.h"
#import "CoreBusStop.h"
#import "BusStop.h"
#import "DataURLConnection.h"
#import "BusTimeCell.h"
#import "Bus.h"
#import "ViewController.h"
@interface TransitViewController () <UITableViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableArray *busStops;
@property (strong, nonatomic) NSMutableArray *busInfos;
@property (nonatomic, strong) NSMutableData   *buffer;
@property (nonatomic, strong) DataURLConnection *connection;


@end

@implementation TransitViewController {
    bool edit;
    bool wait;
}
@synthesize managedObjectContext;
NSIndexPath *currentSelectedIndexPath;
- (void)viewDidLoad {
    [super viewDidLoad];

    
    wait = false;
    //Cosmetics
    self.busTable.layer.cornerRadius = 2;
    self.busTable.layer.masksToBounds = YES;
    
    self.busStops = [[NSMutableArray alloc] init];
    self.busInfos = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CoreBusStop" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSError *error;
    
    
    //load the bus info from coredata. This is bus stop ids and their nicknames.
    //ex bus.name = "home" bus.busNo = "12345"
    self.busInfos = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    
    BusStop *tempBusStop = [[BusStop alloc] init];
    
    for (CoreBusStop * b in self.busInfos)
    {
        tempBusStop = [[BusStop alloc] init];
        tempBusStop.name = b.name;
        tempBusStop.busNo = b.busNo;
        tempBusStop.busesandtimes = [[NSMutableArray alloc] init];
        tempBusStop.expanded = false; //if true this bustop is selected and will display its info
        tempBusStop.upToDate = false; //if true requests to transllink need not be made
        tempBusStop.busErr = false;   //if true an error has occured. ie a bad bus stop was used.
        
        [self.busStops addObject:tempBusStop];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBusStops:) name:@"removeBusStops" object:nil];

    
    // Do any additional setup after loading the view.
}

-(IBAction)addBusStop:(id)sender
{
    //open popup menu
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Add New Bus Stop"
                                                      message:@"Enter a name and stop number for this bus stop and press Add"
                                                     delegate:nil
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:nil];
    message.delegate = self;
    [message setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[message textFieldAtIndex:1] setSecureTextEntry:NO];
    [message textFieldAtIndex:0].placeholder = @"Enter Name";
    [message textFieldAtIndex:1].placeholder = @"Enter 5 Digit Bus Number";
    [message addButtonWithTitle:@"Add"];
    
    [message show];
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Add"] )
    {
        CoreBusStop *busStop = [NSEntityDescription insertNewObjectForEntityForName:@"CoreBusStop" inManagedObjectContext:managedObjectContext];
        
        BusStop *tempBusStop = [[BusStop alloc] init];
        
        busStop.name = [alertView textFieldAtIndex:0].text;
        busStop.busNo = [alertView textFieldAtIndex:1].text;
        
        NSError *error;
        if(![managedObjectContext save:&error]){
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            return;
        }
        
        tempBusStop.name = [alertView textFieldAtIndex:0].text;
        tempBusStop.busNo = [alertView textFieldAtIndex:1].text;
        tempBusStop.busesandtimes = [[NSMutableArray alloc] init];
        tempBusStop.expanded = false;
        tempBusStop.upToDate = false;
        tempBusStop.busErr = false;
        
        [self.busStops addObject:tempBusStop];
        [self.busTable reloadData];
    }
    
    if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Remove"] )
    {
        
        BusStop *tempBusStop = [self.busStops objectAtIndex:currentSelectedIndexPath.row];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        fetch.entity = [NSEntityDescription entityForName:@"CoreBusStop" inManagedObjectContext:managedObjectContext];
        
        fetch.predicate = [NSPredicate predicateWithFormat:@"name == %@", tempBusStop.name];
        
        NSError *error;
        NSArray *ar = [NSMutableArray arrayWithArray:[managedObjectContext executeFetchRequest:fetch error:&error]];
        
        for (CoreBusStop *b in ar){
            [managedObjectContext deleteObject:b];
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                return;
            }
        }
        
        
        [self.busStops removeObject:tempBusStop];
        [self.busTable reloadData];
    }
    
}
-(IBAction)removeBusStops:(id)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Remove bus stop?"
                                                      message:@""
                                                     delegate:nil
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:nil];
    message.delegate = self;
    [message addButtonWithTitle:@"Remove"];
    
    [message show];
}



//Return to main menu
- (void)goBack {
    /*
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *initialViewTransit = [mainStoryboard instantiateInitialViewController];
        initialViewTransit.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:initialViewTransit animated:true completion:nil];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *T = [mainStoryboard instantiateInitialViewController];
    [T setManagedObjectContext:self.managedObjectContext];

    T.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:T animated:true completion:nil];
    */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ViewController * T = [storyboard instantiateViewControllerWithIdentifier:@"MainStoryboard"];
    [T setManagedObjectContext:self.managedObjectContext];
    //T.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:T animated:YES completion:nil];

}



//Table Settings
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.busStops count];
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[self.busStops objectAtIndex:indexPath.row] expanded])
        return 40 + (40 * [[[self.busStops objectAtIndex:indexPath.row] busesandtimes] count]);
    else
        return 40;
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( ![[self.busStops objectAtIndex:indexPath.row] expanded] )
        cell.backgroundColor = [UIColor colorWithRed:(146/255.0) green:(146/255.0) blue:(146/255.0) alpha:1];
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }           
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    BusStop *busStop = [self.busStops objectAtIndex:indexPath.row];
    
    if (busStop.busErr)
    {
        /*
        busStop.expanded = false;
        static NSString *CellIdentifier = @"BusTimeCell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = @"No bus times.";
        */
        busStop.expanded = false;
        static NSString *CellIdentifier = @"BusTimeCellE";
        BusTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BusTimeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
        }
        
        cell.nameLabel.text = @"No Bus Times";

        
        return cell;
    }
    
    // if expanded is true this busstop is selected. display the stops info
    //with times for each bus each on its own line
    else if ([[self.busStops objectAtIndex:indexPath.row] expanded]){
        static NSString *CellIdentifier = @"BusTimeCell2";
        BusTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BusTimeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
        }

        cell.nameLabel.text = busStop.name;
        cell.table.delegate   = cell;
        cell.table.dataSource = cell;
        cell.BusNos = busStop.busesandtimes;
        
        
        return cell;
    }
    //else this stop is not selecded. only show the name on one line.
    else
    {
        static NSString *CellIdentifier = @"BasicTableCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = busStop.name;
        
        return cell;
    }
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    currentSelectedIndexPath = indexPath;
    /*
    if (edit) {
        
        //open popup menu
        NSString *title = @"Remove ";
        
        title = [title stringByAppendingString:[[self.busStops objectAtIndex:indexPath.row] name]];
        
        title = [title stringByAppendingString:@" Bus Stop?"];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:title
                                                          message:@""
                                                         delegate:nil
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:nil];
        [message addButtonWithTitle:@"Remove"];
        message.delegate = self;
        
        edit = false;
        //self.highlightButton.backgroundColor = [UIColor colorWithRed:(166/255.0) green:(25/255.0) blue:(46/255.0) alpha:1];
        [message show];
        
    }
    */
    if (!wait)
    {
        [[self.busStops objectAtIndex:indexPath.row] setExpanded:![[self.busStops objectAtIndex:indexPath.row] expanded]];
        
        
        if(![[self.busStops objectAtIndex:indexPath.row] upToDate]){
            
            //  NSArray *BusNos = [[self.busStops objectAtIndex:indexPath.row] busNos];
            
            
            NSString *num = [[self.busStops objectAtIndex:indexPath.row] busNo];
            [self makeRequest:num];
            
            // [[self.busStops objectAtIndex:indexPath.row] setUpToDate:@YES];
        }
        
        NSArray *rows = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.busTable reloadRowsAtIndexPaths:rows withRowAnimation:NO];
    }
    
}


#pragma mark - Connection

- (void)makeRequest:(NSString*)busstop
{
    
    //activated by fetch button
    /* disable the fetch button during the request */
    //[sender setEnabled:NO];
    
    
    NSString *url = [NSString stringWithFormat:@"http://api.translink.ca/rttiapi/v1/stops/%@/estimates?apikey=KqdSLhzbFx51L6jtCurU&count=3&timeframe=1440",busstop];
    
    /* create the request */
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //return JSON rather than XML data, for easier parsing.
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    /* create the connection */
    //    self.connection = [DataURLConnection connectionWithRequest:request delegate:self];
    self.connection = [[DataURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    /* ensure the connection was created */
    if (self.connection)
    {
        wait = true;
        /* initialize the buffer */
        self.buffer = [NSMutableData data];
        
        /* start the request */
        [self.connection start];
    }
    else
    {
        wait = false;
        NSLog(@"Connection Error BusTimes");
    }
}

- (NSMutableArray *) handleTranslinkJsonResponse:(NSArray *)jsonResponse
{
    //parse the response given by translink.
    // if no errors occur, get the next three departure times for each bus at the requested stop.
    
    //error occured. ie bad bus number or no busses found.
    @try {
        
        NSDictionary *jsonResponseAsDic = jsonResponse;
        
        NSString * code = [jsonResponseAsDic objectForKey:@"Code"];
        
        if (code != nil)
        {
            
            NSMutableArray *errorArray = [[NSMutableArray alloc] init];
            
            [errorArray addObject:@"Error"];
            [errorArray addObject:code];
            [[self.busStops objectAtIndex:currentSelectedIndexPath.row] setBusErr:true];
            return errorArray;
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    
    
    // for each bus get the next 3 departues.
    NSMutableArray *outArray = [[NSMutableArray alloc] init];
    Bus *bus;
    for (NSDictionary *busname in jsonResponse)
    {
        
        if ([busname isEqual:@"Code"])
        {
            [outArray addObject:@"ERROR"];
            return outArray;
        }
        
        bus = [[Bus alloc] init];
        bus.times = [[NSMutableArray alloc] init];
        
        bus.name = [busname objectForKey:@"RouteNo"];
        
        NSArray *Schedules = [busname objectForKey:@"Schedules"];
        
        for (NSDictionary *s in Schedules)
        {
            NSString *ExpectedLeaveTime = [s objectForKey:@"ExpectedLeaveTime"];
            [[bus times] addObject:ExpectedLeaveTime];
        }
        
        [outArray addObject:bus];
    }
    
    return outArray;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /* reset the buffer length each time this is called */
    // [self.buffer setLength:0];
    ((DataURLConnection *)connection).data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /* Append data to the buffer */
    // [self.buffer appendData:data];
    [((DataURLConnection *)connection).data appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    /* clear the connection &amp; the buffer */
    self.connection = nil;
    self.buffer     = nil;
    
    // self.textField.text = [error localizedDescription];
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    wait = false;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    wait = false;

    
    // ((DataURLConnection *)connection).onComplete();
    
    // dispatch off the main queue for json processing
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        //NSString *jsonString = [[NSJSONSerialization JSONObjectWithData:_buffer options:0 error:&error] description];
        NSArray *jsonResponse = [NSJSONSerialization JSONObjectWithData:_connection.data options:0 error:&error];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if (!error)
            {
                
                NSMutableArray *busandtimes = [self handleTranslinkJsonResponse:jsonResponse];
                
                [[self.busStops objectAtIndex:currentSelectedIndexPath.row] setUpToDate:@YES];
                [[self.busStops objectAtIndex:currentSelectedIndexPath.row] setBusesandtimes:busandtimes];
                
                NSArray *rows = [[NSArray alloc] initWithObjects:currentSelectedIndexPath, nil];
                [self.busTable reloadRowsAtIndexPaths:rows withRowAnimation:NO];
                
            }
            else
            {
                //self.textField.text = [error localizedDescription];
            }
        });
        
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
