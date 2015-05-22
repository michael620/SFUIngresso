//
//  RSSManager.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-15.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "RSSManager.h"

@interface RSSManager ()  <NSXMLParserDelegate> {
    
    NSMutableArray *peoplefeeds;
    NSMutableArray *sportsfeeds;
    NSMutableArray *researchfeeds;
    NSMutableArray *communityfeeds;
    NSMutableArray *learningfeeds;
    
    NSMutableArray *feeds;
    NSXMLParser *parser;
    NSMutableArray *heights;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *img;
    NSMutableString *imglink;
    NSString *element;
}

@end

@implementation RSSManager
@synthesize allfeeds,selectedFeeds,outfeeds;

// this object is shared throughout the program. Only created when first called, then used by any class after that.
+ (id) sharedManager {
    static RSSManager *sharedRSSManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRSSManager = [[self alloc] init];
    });
    
    return sharedRSSManager;
}

-(NSMutableArray *) getFeeds {
    
    return outfeeds;
}

//load the image object of each feed element
//first 3
-(void) loadFirstThreeImages {
    if([allfeeds count] >= 3) {
        for (int i=0;i<3;i++)
        {
            NSMutableDictionary * itemToAdd = [NSMutableDictionary dictionaryWithDictionary:[allfeeds objectAtIndex:i]];
            
            
            UIImage * im = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[itemToAdd objectForKey:@"imglink"]]]];
            
            if(im)
                [itemToAdd setObject:im forKey:@"img"];
            
            [allfeeds replaceObjectAtIndex:i withObject:itemToAdd];
            
            for (int o=0;o<[outfeeds count];o++)
            {
                if ([[[outfeeds objectAtIndex:o] objectForKey:@"link"]  isEqual: [itemToAdd objectForKey:@"link"]])
                {
                    [outfeeds replaceObjectAtIndex:o withObject:itemToAdd];
                }
            }
            
        }
    }
}

//load the image object of each feed element
//remainder
-(void) loadRemainingImages {
    if([allfeeds count] >= 3) {
        for (int i=3;i<[allfeeds count];i++)
        {
            NSMutableDictionary * itemToAdd = [NSMutableDictionary dictionaryWithDictionary:[allfeeds objectAtIndex:i]];
            
            
            UIImage * im = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[itemToAdd objectForKey:@"imglink"]]]];
            
            if(im)
                [itemToAdd setObject:im forKey:@"img"];
            
            [allfeeds replaceObjectAtIndex:i withObject:itemToAdd];
            
            for (int o=0;o<[outfeeds count];o++)
            {
                
                if ([[[outfeeds objectAtIndex:o] objectForKey:@"link"]  isEqual: [itemToAdd objectForKey:@"link"]]
                    && !([[[outfeeds objectAtIndex:o] objectForKey:@"img"]  isEqual: [itemToAdd objectForKey:@"img"]]))
                {
                    [outfeeds replaceObjectAtIndex:o withObject:itemToAdd];
                    
                    NSIndexSet *ind = [NSIndexSet indexSetWithIndex:o];
                    
                    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:ind forKey:@"index"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil userInfo:dictionary];
                    
                    
                }
            }
        }
        
        
    }
}

-(id) init {
    
    
    
    selectedFeeds = [[ NSMutableArray alloc] init];
    
    //start with all arrays selected, for now, soon save and take from core data
    selectedFeeds[0] = @YES;
    selectedFeeds[1] = @NO;
    selectedFeeds[2] = @NO;
    selectedFeeds[3] = @NO;
    selectedFeeds[4] = @NO;
    
    outfeeds = [[NSMutableArray alloc] init];
    
    allfeeds = [[NSMutableArray alloc] init];
    
    peoplefeeds = [[NSMutableArray alloc] init];
    sportsfeeds = [[NSMutableArray alloc] init];
    researchfeeds = [[NSMutableArray alloc] init];
    communityfeeds = [[NSMutableArray alloc] init];
    learningfeeds = [[NSMutableArray alloc] init];
    
    feeds = [[NSMutableArray alloc] init];
    heights = [[NSMutableArray alloc] init];
    //NSURL *url = [NSURL URLWithString:@"http://www.sfu.ca/content/sfu/sfunews/community/jcr:content/main_content/list.feed"];
    
    //  NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/feeds/page.php?id=694946660578614&format=rss20"];
    //NSURL *url = [NSURL URLWithString:@"http://www.sfu.ca/sfunews/sports.html"];
    
    if(true) {
        //people
        NSURL *url = [NSURL URLWithString:@"https://gist.githubusercontent.com/amedhiou/edaf3503dd083d57c5ca/raw/baba97913031cb6f7088d46eca8fff644663e1eb/people.feed"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            feeds = [[NSMutableArray alloc] init];
            parser = [[NSXMLParser alloc] initWithData:returnedData];
            [parser setDelegate:self];
            [parser setShouldResolveExternalEntities:NO];
            [parser parse];
            
        });
        
        peoplefeeds = [NSMutableArray arrayWithArray:feeds];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectNewsFeeds:) name:@"selectNewsFeeds" object:nil];
    
    allfeeds = [NSMutableArray arrayWithArray:[allfeeds arrayByAddingObjectsFromArray:peoplefeeds]];

    
    [self orginizeOutArray];
    
    return self;
}

- (void) selectNewsFeeds : (NSNotification *) note
{
    NSIndexPath *indexPath = [[note userInfo] valueForKey:@"index"];
    selectedFeeds[indexPath.row] = [selectedFeeds[indexPath.row]  isEqual: @YES] ? @NO : @YES;
    [self orginizeOutArray];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadWholeTable" object:nil userInfo:nil];
}

- (void) orginizeOutArray
{
    outfeeds = [[NSMutableArray alloc] init];
    
    NSRange range;
    range.location = 0;
    
    if ([[selectedFeeds objectAtIndex:0]  isEqual: @YES])
    {
        range.length = [peoplefeeds count];
        outfeeds = [NSMutableArray arrayWithArray:[outfeeds arrayByAddingObjectsFromArray:[allfeeds subarrayWithRange:range]]];
    }
    
    if ([[selectedFeeds objectAtIndex:1]  isEqual: @YES])
    {
        range.location = [peoplefeeds count];
        range.length = [sportsfeeds count];
        outfeeds = [NSMutableArray arrayWithArray:[outfeeds arrayByAddingObjectsFromArray:[allfeeds subarrayWithRange:range]]];
    }
    
    if ([[selectedFeeds objectAtIndex:2]  isEqual: @YES])
    {
        range.location = [peoplefeeds count] + [sportsfeeds count];
        range.length = [researchfeeds count];
        outfeeds = [NSMutableArray arrayWithArray:[outfeeds arrayByAddingObjectsFromArray:[allfeeds subarrayWithRange:range]]];
    }
    
    if ([[selectedFeeds objectAtIndex:3]  isEqual: @YES])
    {
        range.location = [peoplefeeds count] + [sportsfeeds count] + [researchfeeds count];
        range.length = [communityfeeds count];
        outfeeds = [NSMutableArray arrayWithArray:[outfeeds arrayByAddingObjectsFromArray:[allfeeds subarrayWithRange:range]]];
    }
    
    if ([[selectedFeeds objectAtIndex:4]  isEqual: @YES])
    {
        range.location = [peoplefeeds count] + [sportsfeeds count] + [researchfeeds count] + [communityfeeds count];
        range.length = [learningfeeds count];
        outfeeds = [NSMutableArray arrayWithArray:[outfeeds arrayByAddingObjectsFromArray:[allfeeds subarrayWithRange:range]]];
    }
    
    
    
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    element = elementName;
    
    if ([element isEqualToString:@"entry"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[    NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        
        imglink = [[NSMutableString alloc] init];
        img     = [[NSMutableString alloc] init];
        
    }
}

- (void) parser:(NSXMLParser *) parser foundCharacters:(NSString *)string
{
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"id"]) {
        
        [link appendString:string];
        [link appendString:@".html"];
        
    }
    else if ([element isEqualToString:@"logo"]){
        [imglink appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"entry"]) {
        
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];
        
        
        [item setObject:imglink forKey:@"imglink"];
        
        [feeds addObject:[item copy]];
    }
    
}
/*
 - (void)parserDidEndDocument:(NSXMLParser *)parser {
 
 for (int i=0;i<[feeds count];i++)
 {
 NSMutableDictionary * itemToAdd = [NSMutableDictionary dictionaryWithDictionary:[feeds objectAtIndex:i]];
 
 UIImage * im = [UIImage imageNamed:@"black.jpg"];
 
 [itemToAdd setObject:im forKey:@"img"];
 
 [feeds replaceObjectAtIndex:i withObject:itemToAdd];
 }
 }*/

@end

