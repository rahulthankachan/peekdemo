###Peek Demo App

The goal of this project is to create a a small iPhone application that queries Twitter for the mentions of @Peek.

###Frameworks Used
1. **Twitter Fabric** : Used for user authentication using the Twitter API. 

2. **SvPullToRefresh** : Used for Pull to refresh and infinite scrolling.

3. **SBJson**: To convert the Data into Dicionary Format


###Description

The application uses the Twitter REST API to query tweets which meet the criteria. In this application all the tweets which have the @peek mention are grabbed. 

TO NOTE

1. Intially the latest 10 tweets are grabbed.
2. More Tweets ( 5 at a time) can be grabbed using lazy loading.
3. Pull to refrsh functionality can be used to grab the latest tweets.


###Screenshots!

![Image1](https://github.com/rahulthankachan/peekdemo/blob/master/IMG_1815.jpg)





###Important Snippets


#####Using Twitter API

```
NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    NSDictionary *params = @{@"q" : toSearch, @"count" : @"2", @"result_type": @"recent", @"since_id" :currentSinceId};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];


````
#####Caching images for smooth scrolling


````
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

````











