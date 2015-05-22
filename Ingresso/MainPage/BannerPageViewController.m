//
//  BannerPageViewController.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-16.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "BannerPageViewController.h"
#import "BannerDetailViewController.h"
#import "MainPageRssViewController.h"
#import "RSSManager.h"
#import <dispatch/dispatch.h>

@interface BannerPageViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray * pages;
@property (strong, nonatomic) NSMutableArray * headlines;
@property (strong, nonatomic) NSMutableArray * imgs;
@property (strong, nonatomic) NSMutableArray * links;
@property (weak, nonatomic) RSSManager * rss;


@end

@implementation BannerPageViewController
{
    int currentIndex;
}
@synthesize settings;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    settings = [[NSMutableDictionary alloc] init];
    [settings setValue:@YES forKey:@"RSS"];
    
    CGRect frame = [self.view frame];
    
    UIImageView *rightArrow =[[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 25,160,20,100)];
    //rightArrow.image=[UIImage imageNamed:@"rightarrow"];
    rightArrow.layer.zPosition = MAXFLOAT;
    rightArrow.hidden = NO;
    [self.view addSubview:rightArrow];
    
    UIImageView *leftArrow =[[UIImageView alloc] initWithFrame:CGRectMake(5,160,20,100)];
    //leftArrow.image=[UIImage imageNamed:@"leftarrow"];
    leftArrow.layer.zPosition = MAXFLOAT;
    leftArrow.hidden = YES;
    [self.view addSubview:leftArrow];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSettings:) name:@"updateSettings" object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        _pages = [[NSMutableArray alloc] init];
        
        _imgs = [[NSMutableArray alloc] init];
        _headlines = [[NSMutableArray alloc] init];
        _links = [[NSMutableArray alloc] init];
        
        
        if ([[settings objectForKey:@"RSS"]  isEqual: @YES])
        {
            self.rss = [RSSManager sharedManager];
            if ([[self.rss allfeeds] count] >= 3)
                [self.rss loadFirstThreeImages];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
        for (int i = 0;i<3;i++)
        {
            
            if ([[settings objectForKey:@"RSS"]  isEqual: @YES])
                
            {
                if ([[self.rss allfeeds] count] >= 3) {
                    MainPageRssViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainPageRssViewController"];
                    pageContentViewController.img = [[self.rss.allfeeds objectAtIndex:i] objectForKey:@"img"];
                    pageContentViewController.link = [[self.rss.allfeeds objectAtIndex:i] objectForKey:@"link"];
                    pageContentViewController.headline = [[self.rss.allfeeds objectAtIndex:i] objectForKey:@"title"];
                    pageContentViewController.bannerType = @"RSS";
                    
                    [self.pages addObject:pageContentViewController];
                }
                
            }
        }
        // Create page view controller
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        // self.pageViewController = [[UIPageViewController alloc] init];
        self.pageViewController.delegate = self;
        self.pageViewController.dataSource = self;
        self.pageViewController.view.backgroundColor = [UIColor colorWithRed:(25/255.0) green:(25/255.0) blue:(25/255.0) alpha:1.0];
        
        currentIndex = 0;
        BannerDetailViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers;
        if(startingViewController)
            viewControllers = @[startingViewController];
        else
            viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"NoInternet"]];
        
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [self addChildViewController:_pageViewController];
        self.pageViewController.view.frame = self.view.frame;
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        });
        
    });
    
}

-(void) pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{

    NSUInteger index = [[pendingViewControllers objectAtIndex:0] pageIndex];
    [[[self.view subviews] objectAtIndex:0] setHidden:YES];

    [[[self.view subviews] objectAtIndex:1] setHidden:YES];
 
    if (index < [self.pages count] - 1){
        [[[self.view subviews] objectAtIndex:0] setHidden:NO];
    }
    
    if (index > 0){
        
        [[[self.view subviews] objectAtIndex:1] setHidden:NO];
    }
}

-(void) updateSettings : (NSNotification *) note
{
    //settings
    NSString * path = [[note userInfo] objectForKey:@"feed"];
    if([[settings objectForKey:path]  isEqual: @YES]){
        [settings setValue:@NO forKey:path];
    }
    else
        [settings setValue:@YES forKey:path];
    
}

- (void) loadPageContents
{
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
    
        for (int i = 0;i<3;i++)
        {
            
            if ([[settings objectForKey:@"RSS"]  isEqual: @YES])
                
            {
                if ([[self.rss allfeeds] count] >= 3) {
                    MainPageRssViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainPageRssViewController"];
                    pageContentViewController.img = [[self.rss.allfeeds objectAtIndex:i] objectForKey:@"img"];
                    pageContentViewController.link = [[self.rss.allfeeds objectAtIndex:i] objectForKey:@"link"];
                    pageContentViewController.headline = [[self.rss.allfeeds objectAtIndex:i] objectForKey:@"title"];
                    pageContentViewController.bannerType = @"RSS";
                    
                    [self.pages addObject:pageContentViewController];
                }
                
            }
            
        }
        // Create page view controller
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        // self.pageViewController = [[UIPageViewController alloc] init];
        self.pageViewController.dataSource = self;
        self.pageViewController.view.backgroundColor = [UIColor colorWithRed:(25/255.0) green:(25/255.0) blue:(25/255.0) alpha:1.0];
        
        BannerDetailViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [self addChildViewController:_pageViewController];
        self.pageViewController.view.frame = self.view.frame;
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        
    });
    
    
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((BannerDetailViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((BannerDetailViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    if (index == [self.pages count]) {
        return nil;
    }
    
    index++;
    return [self viewControllerAtIndex:index];
}



- (BannerDetailViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pages count] == 0) || (index >= [self.pages count])) {
        return nil;
    }
    
    BannerDetailViewController * pageContentViewController = [self.pages objectAtIndex:index];
    NSString *bannerType = [pageContentViewController bannerType];
    
    if ( [bannerType  isEqual: @"RSS"]){
        
        // Create an RSS ViewController
        MainPageRssViewController *pageContentViewController = [self.pages objectAtIndex:index];
        pageContentViewController.pageIndex = index;
        
    }

    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
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
