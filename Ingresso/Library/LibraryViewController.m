//
//  LibraryViewController.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-13.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "LibraryViewController.h"
#import "ViewController.h"
#import "LibraryManager.h"
#import "libCell.h"

@interface LibraryViewController () <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSString * userID;
    NSString * action;
    NSInteger numberCheckedOut;
    NSMutableArray * libraryitems;
    NSString * name;
    NSString * amountDue;
}
@property (strong, nonatomic) LibraryManager * libManager;
@end

@implementation LibraryViewController
@synthesize libTable, libManager, web;

- (void)viewDidLoad {
    [super viewDidLoad];
    libTable.delegate = self;
    libTable.dataSource = self;
    
    libraryitems = [[NSMutableArray alloc] init];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadLibTable" object:nil];
        libManager = [LibraryManager sharedManager];
        
        
    });
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        libraryitems = libManager.libraryitems;
        name = libManager.name;
        amountDue = libManager.amountDue;
        [libTable reloadData];
        
        self.checkedOutLabel.text = [@([libraryitems count]) stringValue];
        self.checkedOutLabel.text  =  [self.checkedOutLabel.text stringByAppendingString:@" Items Checked Out"];
        self.checkedOutLabel.textAlignment = NSTextAlignmentCenter;
        

        
        if (libManager.signedIn)
        {
            [self.signInButton setTitle:(@"%@",libManager.name) forState:(UIControlStateNormal)];
            self.amountDueLabel.text = [@"Amount Due : " stringByAppendingString:(@"%@",amountDue)];

        }

    });
}


//Sign In button
- (IBAction)signIn:(id)sender {
    if (libManager.signedIn == false)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Sign In"
                                                          message:@"Enter your last/family name and library barcode found on your SFU ID"
                                                         delegate:nil
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:nil];
        message.delegate = self;
        [message setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        [[message textFieldAtIndex:1] setSecureTextEntry:NO];
        [message textFieldAtIndex:0].placeholder = @"Last/Family Name";
        [message textFieldAtIndex:1].placeholder = @"Library Card Barcode; eg 29345...";
        [message addButtonWithTitle:@"Sign In"];
        
        [message show];
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Sign Out"
                                                          message:@"Would you like to sign out?"
                                                         delegate:nil
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:nil];
        message.delegate = self;
        [message addButtonWithTitle:@"Sign Out"];
        
        [message show];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Sign In"] )
    {
        libManager.login = [alertView textFieldAtIndex:0].text;
        libManager.password = [alertView textFieldAtIndex:1].text;
        [libManager signIn];
    
    }
    if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Sign Out"] )
    {
        libManager.login = @"";
        libManager.password = @"";
        [libManager signOut];
        [self reloadTable];
        [self.signInButton setTitle:@"Sign In" forState: UIControlStateNormal];
        self.amountDueLabel.text = @"Amount Due : $0.00";

    }
    
}

- (void)reloadTable {
    
    libraryitems = libManager.libraryitems;
    amountDue = libManager.amountDue;
    [libTable reloadData];
    
    self.checkedOutLabel.text = [@([libraryitems count]) stringValue];
    self.checkedOutLabel.text  =  [self.checkedOutLabel.text stringByAppendingString:@" Items Checked Out"];
    self.checkedOutLabel.textAlignment = NSTextAlignmentCenter;
    
    if (libManager.signedIn)
    {
        [self.signInButton setTitle:(@"%@",libManager.name) forState:(UIControlStateNormal)];
        self.amountDueLabel.text = [@"Amount Due : " stringByAppendingString:(@"%@",amountDue)];

    }
}


-(IBAction)renewSelected:(id)sender
{
    
    [libManager renewSelected:libTable];
    
}
/*
-(void) webViewDidFinishLoad:(UIWebView *)webView {
    
    NSString *url = [web stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    NSArray *  urlsplit = [url componentsSeparatedByString:@"/"];
    NSString * place = @"";
    if ([urlsplit count] > 4)
        place = [urlsplit objectAtIndex:5];
    
    if ([url  isEqual: @"https://troy.lib.sfu.ca/patroninfo"])
    {
        NSString *savedUsername = @"Cheng";
        NSString *savedPassword = @"29345006524181";
        NSString *loadUsernameJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[name='name']\"); \
                                    for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", savedUsername];
        NSString *loadPasswordJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[name='code']\"); \
                                    for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", savedPassword];
        
        [web stringByEvaluatingJavaScriptFromString: loadUsernameJS];
        [web stringByEvaluatingJavaScriptFromString: loadPasswordJS];
        
        NSString *performSubmitJS = @"var passFields = document.querySelectorAll(\"input[name='submit']\"); \
        passFields[0].click()";
        [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        
    }
    
    //Sucessfully signed in, go to items checked out
    else if ([place  isEqual: @"top"])
    {
        userID = [urlsplit objectAtIndex:4];
        url = [NSString stringWithFormat:@"https://troy.lib.sfu.ca/patroninfo~S1/%@/items",userID];
        
        NSURL *myURL = [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:
                                              NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
        
        [web loadRequest:request];
    }
    
    else if ([action  isEqual: @"RENEWALL"])
    {
        NSString *performSubmitJS = @"var renew = document.querySelectorAll(\"input[name='renewsome']\"); \
        renew[0].click()";
        [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        action = @"RENEWCOMPLETE";
    }
    
    else if ([action  isEqual: @"RENEWCOMPLETE"] && [place  isEqual: @"items"])
    {
        libraryitems = [[NSMutableArray alloc] init];
        
        NSString * performSubmitJS = @"document.getElementsByClassName(\"patFunc\")[0].tBodies[0].rows.length";
        NSString * str = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        numberCheckedOut = [str integerValue] - 2;
        
        str = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        
        for (int i = 0; i < numberCheckedOut; i++)
        {
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncTitleMain\")[%d].innerHTML",i];
            NSString * bookName = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncStatus\")[%d].innerHTML.replace(/<[^>]*>/g, \"\")",i];
            NSString * dueDate = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            // dueDate = [dueDate substringToIndex:12];
            //  dueDate = [dueDate substringFromIndex:1];
            
            
            
            
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncStatus\")[%d].getElementsByTagName('em')[0].innerText",i];
            NSString * warning = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncRenewCount\")[%d].innerHTML",i];
            NSString * renewCount = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            NSMutableDictionary * bookItem = [[NSMutableDictionary alloc] init];
            
            [bookItem setValue:bookName forKey:@"bookName"];
            [bookItem setValue:dueDate forKey:@"dueDate"];
            [bookItem setValue:renewCount forKey:@"renewCount"];
            [bookItem setValue:warning forKey:@"warning"];
            
            [libraryitems addObject:bookItem];
            
        }
        
        [libTable reloadData];
    }
    
    //Go to items, load data into view controller table
    else if ([action  isEqual: @"NONE"] && [place  isEqual: @"items"])
    {
        libraryitems = [[NSMutableArray alloc] init];
        
        NSString * performSubmitJS = @"document.getElementsByClassName(\"patFunc\")[0].tBodies[0].rows.length";
        NSString * str = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        numberCheckedOut = [str integerValue] - 2;
        
        str = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        
        for (int i = 0; i < numberCheckedOut; i++)
        {
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncTitleMain\")[%d].innerHTML",i];
            NSString * bookName = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncStatus\")[%d].innerHTML.replace(/<[^>]*>/g, \"\")",i];
            NSString * dueDate = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            //  dueDate = [dueDate substringToIndex:12];
            //   dueDate = [dueDate substringFromIndex:1];
            
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncRenewCount\")[%d].innerHTML",i];
            NSString * renewCount = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            NSMutableDictionary * bookItem = [[NSMutableDictionary alloc] init];
            
            [bookItem setValue:bookName forKey:@"bookName"];
            [bookItem setValue:dueDate forKey:@"dueDate"];
            [bookItem setValue:renewCount forKey:@"renewCount"];
            
            [libraryitems addObject:bookItem];
            
        }
        
        [libTable reloadData];
    }
    
}
*/
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma tableview

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [libraryitems count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    static NSString *tablecell = @"table";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tablecell];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tablecell];
    }
    
    cell.textLabel.text = [libraryitems[indexPath.row] objectForKey:@"bookName"];
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [libraryitems[indexPath.row] objectForKey:@"dueDate"];

    
    return cell;
     */
    
    static NSString *simpleTableIdentifier = @"libCell";
    
    libCell *cell = (libCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"libCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.bookName.text = [libraryitems[indexPath.row] objectForKey:@"bookName"];
    cell.dueDateTextView.text = [libraryitems[indexPath.row] objectForKey:@"dueDate"];
    cell.dueDateTextView.text = [cell.dueDateTextView.text stringByAppendingString:[libraryitems[indexPath.row] objectForKey:@"renewCount"]];
    cell.warningTextView.text = [libraryitems[indexPath.row] objectForKey:@"warning"];

    [cell.bookName setFont:[UIFont systemFontOfSize:18.0f]];
    //cell.bookName.backgroundColor = [UIColor colorWithRed:(150/255.0) green:(150/255.0) blue:(150/255.0) alpha:1];
    //cell.warningTextView.backgroundColor = [UIColor colorWithRed:(100/255.0) green:(100/255.0) blue:(100/255.0) alpha:1];
    //cell.dueDateTextView.backgroundColor = [UIColor colorWithRed:(100/255.0) green:(100/255.0) blue:(100/255.0) alpha:1];
    cell.warningTextView.textColor = [UIColor colorWithRed:(255/255.0) green:(0/255.0) blue:(20/255.0) alpha:1];
    [cell.warningTextView setFont:[UIFont systemFontOfSize:12.0f]];
    [cell.dueDateTextView setFont:[UIFont systemFontOfSize:12.0f]];
    cell.dueDateTextView.textAlignment = NSTextAlignmentRight;
    //cell.bookName.textAlignment = NSTextAlignmentJustified;

    
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goBack:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ViewController * T = [storyboard instantiateViewControllerWithIdentifier:@"MainStoryboard"];
    T.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:T animated:YES completion:nil];
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
