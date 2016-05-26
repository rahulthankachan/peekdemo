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

@interface HomeViewController () {

    NSMutableArray * tweets;
    NSMutableDictionary *tweetDict;
}

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
    NSDictionary *params = @{@"q" : @"%40peek", @"count" : @"2", @"result_type": @"recent"};
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
    NSDictionary *tempSegment= [segments objectAtIndex:0];
    NSString * text = [tempSegment objectForKey:@"text"];
    
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
