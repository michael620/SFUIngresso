//
//  BeedieViewController.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-11.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "BeedieViewController.h"
#import "ViewController.h"
@interface BeedieViewController ()

@end

@implementation BeedieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *url = @"https://cas.sfu.ca/cgi-bin/WebObjects/cas.woa/wa/login?message=Note:+website+issue+where+students+cannot+login+on+the+first+try.+Try+again.&service=https://beediecommunity.sfu.ca/sfuLogin.htm%3Faction%3Dlogin";
    NSURL *myURL = [NSURL URLWithString: url];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL]; [self.BeedieWebView loadRequest:request];

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
