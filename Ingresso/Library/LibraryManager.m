//
//  LibraryManager.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-15.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "LibraryManager.h"
#import "libCell.h"

@interface LibraryManager () <UIWebViewDelegate> {
    NSString * userID;
    
    //NSString * action;
    int numLate,numSoonLate;
    BOOL attempt;
    BOOL finished;
}

@end


@implementation LibraryManager
@synthesize web,libraryitems,numberCheckedOut,action;

+ (id) sharedManager {
    static LibraryManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(void) renewAll {
    action = @"RENEWALL";
    NSString *performSubmitJS = @"";
    
    for (int i = 0; i < numberCheckedOut; i++)
    {
        
        NSString *performSubmitJS = [NSString stringWithFormat:@"var radio = document.querySelectorAll(\"input[name='renew%d']\"); \
                                     radio[0].click()",i];
        [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        
    }
    
    performSubmitJS = @"var passFields = document.querySelectorAll(\"input[name='requestRenewSome']\"); \
    passFields[0].click()";
    [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
}

-(void) renewSelected : (UITableView *) table{
    action = @"RENEWSELECTED";
    NSString *performSubmitJS = @"";
    
    for (int i = 0; i < numberCheckedOut; i++)
    {
        NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:0];
        
        libCell * cell = (libCell * )[table cellForRowAtIndexPath:path];
        
        if(cell.renewButton.selected)
        {
            NSString *performSubmitJS = [NSString stringWithFormat:@"var radio = document.querySelectorAll(\"input[name='renew%d']\"); \
                                         radio[0].click()",i];
            [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        }
        
        
    }
    
    performSubmitJS = @"var passFields = document.querySelectorAll(\"input[name='requestRenewSome']\"); \
    passFields[0].click()";
    [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
}

-(id) init {
    
    numLate = 0;
    numSoonLate = 0;
    attempt = false;
    action = @"NONE";
    self.web = [[UIWebView alloc] init];
    web.delegate = self;
    self.signedIn = false;
    self.failedsignIn = false;
    finished = false;
    NSString * url = @"https://troy.lib.sfu.ca/patroninfo";
    NSURL *myURL = [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:
                                          NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
    [self.web loadRequest:request];

    
    return self;
}

- (void)restart
{
    action = @"NONE";
    self.web = [[UIWebView alloc] init];
    web.delegate = self;
    
    NSString * url = @"https://troy.lib.sfu.ca/patroninfo";
    NSURL *myURL = [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:
                                          NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
    [self.web loadRequest:request];
}

- (void)signIn
{
    attempt = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLibTable" object:nil userInfo:nil];
    [self restart];
    
}
- (void)signOut
{
    attempt = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLibTable" object:nil userInfo:nil];
    [libraryitems removeAllObjects];
    self.amountDue = @"$0.00";
    [self restart];
}


-(void) webViewDidFinishLoad:(UIWebView *)webView {
    
    NSDate *today = [NSDate date];
    NSDateFormatter *df= [[NSDateFormatter alloc] init];
    
    NSString *url = [web stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    NSArray *  urlsplit = [url componentsSeparatedByString:@"/"];
    NSString * place = @"";
    if ([urlsplit count] > 4)
        place = [urlsplit objectAtIndex:5];
    
    if ([url  isEqual: @"https://troy.lib.sfu.ca/patroninfo"])
    {
        self.signedIn = NO;
        if (attempt == false)
        {
            NSString *loadUsernameJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[name='name']\"); \
                                        for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", _login];
            NSString *loadPasswordJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[name='code']\"); \
                                        for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", _password];
        
            [web stringByEvaluatingJavaScriptFromString: loadUsernameJS];
            [web stringByEvaluatingJavaScriptFromString: loadPasswordJS];
        
            NSString *performSubmitJS = @"var passFields = document.querySelectorAll(\"input[name='submit']\"); \
            passFields[0].click()";
            [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            attempt = true;
        }
    }
    
    
    
    //Logged in successfully, get user full name, go to items checked out page
    else if ([place  isEqual: @"top"])
    {
        self.failedsignIn = false;
        NSString * performSubmitJS = @"document.getElementById(\"patroninfo\").innerHTML";
        NSString * str = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        str = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        
        str = [[str componentsSeparatedByString:@"<br>"] objectAtIndex:1];
        str = [str substringFromIndex:1];
        
        self.name = str;
        
        performSubmitJS = @"document.getElementsByClassName(\"pageMainArea\")[0].getElementsByTagName(\"a\")[3].innerHTML";
        str = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        str = [[str componentsSeparatedByString:@" "] objectAtIndex:0];
        str = [str substringFromIndex:0];
        
        self.amountDue = str;
        
        action = @"NONE";
        userID = [urlsplit objectAtIndex:4];
        url = [NSString stringWithFormat:@"https://troy.lib.sfu.ca/patroninfo~S1/%@/items",userID];
        
        NSURL *myURL = [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:
                                              NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
        self.signedIn = true;
        [web loadRequest:request];
        
    }
    
    else if ([action  isEqual: @"RENEWALL"] || [action  isEqual: @"RENEWSELECTED"])
    {
        NSString *performSubmitJS = @"var renew = document.querySelectorAll(\"input[name='renewsome']\"); \
        renew[0].click()";
        [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        action = @"RENEWCOMPLETE";
    }
    
    else if ([action  isEqual: @"RENEWCOMPLETE"] && [place  isEqual: @"items"])
    {
        
        numLate = 0;
        numSoonLate = 0;
        
        libraryitems = [[NSMutableArray alloc] init];
        
        NSString * performSubmitJS = @"document.getElementsByClassName(\"patFunc\")[0].tBodies[0].rows.length";
        NSString * str = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        numberCheckedOut = [str integerValue] - 2;
        
        
        for (int i = 0; i < numberCheckedOut; i++)
        {
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncTitleMain\")[%d].innerHTML",i];
            NSString * bookName = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName('patFuncStatus')[%d].innerHTML.replace(/ <em.*/g, '').replace(/ <span.*/g, '')",i];
            NSString * dueDateString = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            NSString * dueDate = [dueDateString substringFromIndex:5];
            dueDateString = [dueDateString substringFromIndex:1];
            
            int warningTime = 0;
            if ([dueDate length] > 12){
                
                dueDate = [dueDate substringToIndex:16];
                [df setDateFormat:@"yy-MM-dd'T'hh:mma"];
                warningTime = 5400;
                
            }
            
            else{
                
                dueDate = [dueDate substringToIndex:8];
                [df setDateFormat:@"yy-MM-dd"];
                warningTime = 86400;
                
            }
            
            NSDate * date = [df dateFromString:dueDate];
            
            NSTimeInterval timeToDue = [date timeIntervalSinceDate:today];
            
            if (timeToDue <= 0)
            {
                //LATE!!
                numLate += 1;
            }
            
            if (timeToDue <= warningTime && timeToDue > 0)
            {
                //Due in 24 hours
                numSoonLate += 1;
            }
            
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncStatus\")[%d].getElementsByTagName('em')[0].innerText",i];
            NSString * warning = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncRenewCount\")[%d].innerHTML",i];
            NSString * renewCount = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            NSMutableDictionary * bookItem = [[NSMutableDictionary alloc] init];
            
            [bookItem setValue:bookName forKey:@"bookName"];
            [bookItem setValue:dueDateString forKey:@"dueDate"];
            [bookItem setValue:renewCount forKey:@"renewCount"];
            [bookItem setValue:warning forKey:@"warning"];
            
            [libraryitems addObject:bookItem];
            
        }
        
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[[NSNumber alloc] initWithInt:numLate] forKey:@"num"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"haveLateBooks" object:nil userInfo:dictionary];
        
        
        
        dictionary = [NSDictionary dictionaryWithObject:[[NSNumber alloc] initWithInt:numSoonLate] forKey:@"num"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNearLateBooks" object:nil userInfo:dictionary];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLibTable" object:nil userInfo:nil];
    }
    
    //At items checked out
    else if ([action  isEqual: @"NONE"] && [place  isEqual: @"items"])
    {
        
        numLate = 0;
        numSoonLate = 0;
        
        libraryitems = [[NSMutableArray alloc] init];
        
        
        
        NSString * performSubmitJS = @"document.getElementsByClassName(\"patFunc\")[0].tBodies[0].rows.length";
        NSString * str = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
        numberCheckedOut = [str integerValue] - 2;
        
        for (int i = 0; i < numberCheckedOut; i++)
        {
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncTitleMain\")[%d].innerHTML",i];
            NSString * bookName = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName('patFuncStatus')[%d].innerHTML.replace(/ <em.*/g, '').replace(/ <span.*/g, '')",i];
            NSString * dueDateString = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            NSString * dueDate = [dueDateString substringFromIndex:5];
            
            dueDateString = [dueDateString substringFromIndex:1];
            
            int warningTime = 0;
            if ([dueDate length] > 12){
                
                dueDate = [dueDate substringToIndex:16];
                [df setDateFormat:@"yy-MM-dd'T'hh:mma"];
                warningTime = 5400;
                
            }
            
            else{
                
                dueDate = [dueDate substringToIndex:8];
                [df setDateFormat:@"yy-MM-dd"];
                warningTime = 86400;
                
            }
            
            NSDate * date = [df dateFromString:dueDate];
            
            NSTimeInterval timeToDue = [date timeIntervalSinceDate:today];
            
            if (timeToDue <= 188888880)
            {
                //LATE!!
                numLate += 1;
            }
            
            if (timeToDue <= warningTime + 189498419)
            {
                //Due in 24 hours
                numSoonLate += 1;
            }
            
            performSubmitJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"patFuncRenewCount\")[%d].innerHTML",i];
            NSString * renewCount = [web stringByEvaluatingJavaScriptFromString:performSubmitJS];
            
            NSMutableDictionary * bookItem = [[NSMutableDictionary alloc] init];
            
            [bookItem setValue:bookName forKey:@"bookName"];
            [bookItem setValue:dueDateString forKey:@"dueDate"];
            [bookItem setValue:renewCount forKey:@"renewCount"];
            
            [libraryitems addObject:bookItem];
            
        }
        
        
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[[NSNumber alloc] initWithInt:numLate] forKey:@"num"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"haveLateBooks" object:nil userInfo:dictionary];
        
        
        
        dictionary = [NSDictionary dictionaryWithObject:[[NSNumber alloc] initWithInt:numSoonLate] forKey:@"num"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNearLateBooks" object:nil userInfo:dictionary];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLibTable" object:nil userInfo:nil];
        
        finished = true;
    }
    
}
@end
