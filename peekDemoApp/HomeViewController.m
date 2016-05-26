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
#import "SBJSON.h"
#import "TweetViewCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"


@interface HomeViewController () {

    NSMutableArray * tweets;
    NSMutableDictionary *tweetDict;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewTweets;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tweets = [[NSMutableArray alloc] init];
    tweetDict = [[NSMutableDictionary alloc]init];
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    [client loadTweetWithID:@"20" completion:^(TWTRTweet *tweet, NSError *error) {
        // handle the response or error
    }];

    

    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    NSDictionary *params = @{@"q" : @"%40peek", @"count" : @"10", @"result_type": @"recent"};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError1;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError1];
               NSLog([json description]);
                
                NSString *stringData= [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:nil];
                
                SBJSON *jsonParser= [[SBJSON alloc]init];
                NSError *jsonError;

                tweetDict= [jsonParser objectWithString:stringData error:&jsonError];
                [self performSelectorOnMainThread:@selector(tweetsReceived:) withObject:tweetDict waitUntilDone:NO];
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


-(void)tweetsReceived: (NSMutableDictionary*) mine{
    NSArray * segments = [mine objectForKey:@"statuses"];
    
    for (NSDictionary *tempSegment in segments) {
        TweetData *tweet = [[TweetData alloc]init];
        tweet.dataTweetContent = [tempSegment objectForKey:@"text"];
        NSDictionary *user = [tempSegment objectForKey:@"user"];
        tweet.dataUserName = [user objectForKey:@"name"];
        tweet.dataImageURL = [user objectForKey:@"profile_image_url_https"];
        [tweets addObject:tweet];
    }
    
    [_tableViewTweets reloadData];
    

    
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




#pragma mark Data Model Handlers





#pragma mark TableView Delegate Methods


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tweets count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    TweetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweet" forIndexPath:indexPath];
    
    TweetData *currentTweet = [tweets objectAtIndex:indexPath.row];
    cell.tweetUserName.text = currentTweet.dataUserName;
    cell.tweetContent.text = currentTweet.dataTweetContent;
    
    
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



@end
