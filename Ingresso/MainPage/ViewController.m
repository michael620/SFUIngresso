//
//  ViewController.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-09.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "ViewController.h"
#import "TransitViewController.h"

@interface ViewController ()

@property (strong, nonatomic) ViewController *page;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)goToLibrary:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Library" bundle: nil];
    TransitViewController * B = [storyboard instantiateViewControllerWithIdentifier:@"LibraryStoryboard"];
    B.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:B animated:YES completion:nil];
}

- (IBAction)goToTransit:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Transit" bundle: nil];
    TransitViewController * T = [storyboard instantiateViewControllerWithIdentifier:@"TransitStoryboard"];
    [T setManagedObjectContext:self.managedObjectContext];
    T.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:T animated:YES completion:nil];
}

- (IBAction)goToNews:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"News" bundle: nil];
    TransitViewController * T = [storyboard instantiateViewControllerWithIdentifier:@"NewsStoryboard"];
    //[T setManagedObjectContext:self.managedObjectContext];
    T.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:T animated:YES completion:nil];
}

// This will get called too before the view appears

- (IBAction)goToAcademics:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Academics" bundle: nil];
    TransitViewController * B = [storyboard instantiateViewControllerWithIdentifier:@"AcademicsStoryboard"];
    //[T setManagedObjectContext:self.managedObjectContext];
    B.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:B animated:YES completion:nil];

}
- (IBAction)goToMail:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mail" bundle: nil];
    TransitViewController * B = [storyboard instantiateViewControllerWithIdentifier:@"MailStoryboard"];
    //[T setManagedObjectContext:self.managedObjectContext];
    B.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:B animated:YES completion:nil];
}
    
- (void)didReceiveMemoryWarning {
    //[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
