//
//  RSSTableViewController.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-14.
//  Copyright (c) 2015 pintMates. All rights reserved.
//
#import "RSSTableViewController.h"
#import "RSSDetailViewController.h"
#import "RssCell.h"
#import "RSSManager.h"
#import "ViewController.h"
#import "RSSTableViewController.h"

@interface RSSTableViewController (){
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableArray *heights;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *img;
    NSString *element;
}

@property (weak, nonatomic) RSSManager * rss;

@end

@implementation RSSTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    feeds = [[NSMutableArray alloc] init];
    heights = [[NSMutableArray alloc] init];
    
    
    //dispatch to seperate queue and begin loading the rss feeds
    // sync rather than async to ensure the next step happens after this is done.
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.rss = [RSSManager sharedManager];
        
    });
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        feeds = [self.rss getFeeds];
    });
    //dispatch to get the feeds, will happen only after the feeds have been fetched, as its in sync
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.rss loadFirstThreeImages];
        [self.rss loadRemainingImages];
        
    });
    
    //setup a notification to know when an image has loaded. reloadWholeTable
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"reloadTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWholeTable) name:@"reloadWholeTable" object:nil];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (IBAction)goBack:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ViewController * T = [storyboard instantiateViewControllerWithIdentifier:@"MainStoryboard"];
    T.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:T animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) reloadWholeTable
{
    feeds = [self.rss getFeeds];
    
    [self.table reloadData];
}

-(void) reloadTable : (NSNotification *) note
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexSet *indexpath = [[note userInfo] valueForKey:@"index"];
        
        [self.table reloadData];
        [self.table reloadSections:indexpath withRowAnimation:NO];
    });
    // [self.table reloadInputViews];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return feeds.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
    return feeds.count;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width, 0)];
    
    headerView.backgroundColor = [UIColor colorWithRed:(229/255.0) green:(229/255.0) blue:(229/255.0) alpha:1];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"RssCell";
    
    RssCell *cell = (RssCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RssCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.paddingview.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.7];
    [cell.imageView addSubview:cell.paddingview];
    
    cell.textField.text = [[feeds objectAtIndex:indexPath.section] objectForKey: @"title"];
    cell.textField.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.7];
    //cell.imageView.image = [[feeds objectAtIndex:indexPath.row] objectForKey: @"img"];
    [cell.imageView addSubview:cell.textField];
    cell.imageView.image = [[feeds objectAtIndex:indexPath.section] objectForKey: @"img"];
    
    cell.textField.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    
    NSNumber * h = [NSNumber numberWithDouble: cell.imageView.image.size.height];
    [heights insertObject:h atIndex:indexPath.section];
    
    
    cell.imageView.layer.cornerRadius = 5;
    cell.imageView.layer.masksToBounds = YES;
    cell.spinner.color = [UIColor colorWithRed:(25/255.0) green:(25/255.0) blue:(25/255.0) alpha:0.7];
    [cell.spinner startAnimating ];
    cell.clipsToBounds = YES;
    return cell;
    
    
    
}

//Set Cell Color
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundColor = [UIColor colorWithRed:(229/255.0) green:(229/255.0) blue:(229/255.0) alpha:1];
    
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // cell.contentView.layer.cornerRadius = 5;
    cell.contentView.layer.masksToBounds = YES;
    
    
}

#pragma mark - Navigation

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = [feeds[indexPath.section] objectForKey: @"link"];
    
    RSSDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"RSSDetailView"];
    
    detail.url = string;
    
    [self.navigationController pushViewController:detail animated:YES];
    
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
        [segue destinationViewController];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    @try
    {
        return 200;
        height = [heights[indexPath.row] doubleValue] ;
        
        if (height > 300)
            return 300;
        return height;
    }
    @catch (NSException *e) {
        return 120;
    }
}




@end
