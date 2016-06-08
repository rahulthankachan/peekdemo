//
//  HomeViewController.m
//  peekDemoApp
//
//  Created by Rahul Thankachan on 5/26/16.
//  Copyright © 2016 Rahul Thankachan. All rights reserved.
//

#import "HomeViewController.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import "TweetData.h"
#import "TweetViewCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "UIColor+ColorModule.h"
#import "Enums.h"


@interface HomeViewController () {

    NSMutableArray * tweets;
    NSMutableDictionary *tweetDict;
    NSString *currentMaxID;
    NSString *currentSinceId;
    TWTRAPIClient *client;
    NSMutableArray *deletedTweets;
    NSString *toSearch;
}


@property (weak, nonatomic) IBOutlet UITableView *tableViewTweets;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   toSearch = @"%40Peek";
 //toSearch = @"%40Twitter";
    
    
    currentMaxID = @"";
    currentSinceId = @"";
    tweets = [[NSMutableArray alloc] init];
    tweetDict = [[NSMutableDictionary alloc]init];
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    client = [[TWTRAPIClient alloc] initWithUserID:userID];

    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    NSDictionary *params = @{@"q" : toSearch, @"count" : @"10", @"result_type": @"recent"};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError1;
               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError1];
               
                NSMutableArray *tweetArray = [[NSMutableArray alloc]init];
                [tweetArray addObject:json];
                [tweetArray addObject:[NSNumber numberWithInteger:kInsertPositionBottom]];

                [self performSelectorOnMainThread:@selector(tweetsReceived:) withObject:tweetArray waitUntilDone:NO];
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
    
    self.tableViewTweets.showsPullToRefresh = YES;
    
    // setup pull-to-refresh
    [self.tableViewTweets addPullToRefreshWithActionHandler:^{
        [self insertRowAtTop];
    }];
    
    // setup infinite scrolling
    [self.tableViewTweets addInfiniteScrollingWithActionHandler:^{
        [self insertRowAtBottom];
    }];

}


#pragma mark getOlderTweets

-(void)getOlderTweets{
    
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    NSDictionary *params = @{@"q" : toSearch, @"count" : @"5", @"result_type": @"recent", @"max_id" :currentMaxID};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError1;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError1];
                NSMutableArray *tweetArray = [[NSMutableArray alloc]init];
                [tweetArray addObject:json];
                [tweetArray addObject:[NSNumber numberWithInteger:kInsertPositionBottom]];
                
                [self performSelectorOnMainThread:@selector(tweetsReceived:) withObject:tweetArray waitUntilDone:NO];
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }



}


#pragma mark getRecentTweets

-(void)getLatestTweets{
    
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    NSDictionary *params = @{@"q" : toSearch, @"count" : @"2", @"result_type": @"recent", @"since_id" :currentSinceId};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSError *jsonError1;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError1];

                NSMutableArray *tweetArray = [[NSMutableArray alloc]init];
                [tweetArray addObject:json];
                [tweetArray addObject:[NSNumber numberWithInteger:kInsertPositionTop]];
                
                [self performSelectorOnMainThread:@selector(tweetsReceived:) withObject:tweetArray waitUntilDone:NO];
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
    
    
    
}



#pragma mark Infinite and Pull to Refresh

- (void)insertRowAtTop {
    __weak HomeViewController *weakSelf = self;
    
    [self getLatestTweets];
    
    int64_t delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.tableViewTweets beginUpdates];
        [weakSelf.tableViewTweets endUpdates];
        
        [weakSelf.tableViewTweets.pullToRefreshView stopAnimating];
    });
}




#pragma mark inserrow at bottom
- (void)insertRowAtBottom {
    __weak HomeViewController *weakSelf = self;
    [self getOlderTweets];
    
    int64_t delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.tableViewTweets beginUpdates];
        
        [weakSelf.tableViewTweets endUpdates];
    
        [weakSelf.tableViewTweets.infiniteScrollingView stopAnimating];
    });
}




#pragma mark Tweet Handling


-(void)tweetsReceived: (NSMutableArray*) mine{
    NSDictionary * segmentsD = [mine objectAtIndex:0];
    NSArray *segments  = [segmentsD objectForKey:@"statuses"];
    NSNumber *pos = [mine objectAtIndex:1];
    InsertPosition position = (InsertPosition)[pos integerValue];
    
    
    for (NSDictionary *tempSegment in segments) {
        
        TweetData *tweet = [[TweetData alloc]init];
        tweet.dataTweetContent = [tempSegment objectForKey:@"text"];
        NSDictionary *user = [tempSegment objectForKey:@"user"];
        tweet.dataUserName = [user objectForKey:@"name"];
        tweet.dataImageURL = [user objectForKey:@"profile_image_url_https"];
        tweet.dataTweetID = [tempSegment objectForKey:@"id_str"];
        if (![tweet.dataTweetID isEqualToString:currentSinceId] && ![tweet.dataTweetID isEqualToString:currentMaxID]) {
            
                if (position == kInsertPositionTop) {
                            [tweets insertObject:tweet atIndex:0];
                } else {
                            [tweets addObject:tweet];
                    }
        
        }
        
    }
    
    /// This will update the current counterns for the max and since
    [self updateFirstAndLastIdAfterLoad];
    
    
    
    [self.tableViewTweets reloadData];
    

    
}



#pragma update Max and Since

-(void) updateFirstAndLastIdAfterLoad{
    
    TweetData *lastTweet = [tweets lastObject];
    currentMaxID = lastTweet.dataTweetID;
    TweetData *firstTweet = [tweets firstObject];
    currentSinceId = firstTweet.dataTweetID;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

    

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        [tweets removeObjectAtIndex:indexPath.row];
        [self.tableViewTweets reloadData];
    }
}




#pragma mark TableView DataSource Methods


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tweets count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    TweetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweet" forIndexPath:indexPath];
    
    TweetData *currentTweet = [tweets objectAtIndex:indexPath.row];
    cell.tweetUserName.text = currentTweet.dataUserName;
    cell.tweetContent.text = currentTweet.dataTweetContent;
    
    cell.retweetB.tag = indexPath.row;
    [cell.retweetB addTarget:self action:@selector(tweetButtonSelectedForRow:) forControlEvents:UIControlEventTouchUpInside];
    
    if (indexPath.row%2) {
        cell.backgroundColor = [UIColor kColorRow1];
    } else {
        cell.backgroundColor = [UIColor kColorRow2];
    }
    
    
    if (currentTweet.userImage!=nil) {
        
        cell.tweetUserImage.image = currentTweet.userImage;
    
    } else {
        
        NSURL *url1 = [NSURL URLWithString:currentTweet.dataImageURL];
        
        [self downloadImageWithURL:url1 completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                cell.tweetUserImage.image = image;
                currentTweet.userImage = image;
                
            }
        }];
        
    
    }
    
    
    
    return cell;
}


- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}


-(void)tweetButtonSelectedForRow:(UIButton*)rowButton {
    
    NSInteger rowSelected = rowButton.tag;
    
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    TweetData *selectedTweet = [tweets objectAtIndex:rowSelected];
    [composer setText:selectedTweet.dataTweetContent];
    
    // Called from a UIViewController
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        }
        else {
            UIAlertController *viewController = [UIAlertController alertControllerWithTitle:@"Twitter Message Sent" message:@"Yay!!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *success = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [viewController addAction:success];
            [self presentViewController:viewController animated:YES completion:nil];
        }
    }];
    

}



@end
