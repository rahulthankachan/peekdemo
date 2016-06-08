//
//  TweetViewCell.h
//  peekDemoApp
//
//  Created by Rahul Thankachan on 5/26/16.
//  Copyright © 2016 Rahul Thankachan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetViewCell : UITableViewCell {

}

@property (weak,nonatomic) IBOutlet UILabel *tweetUserName;
@property (weak,nonatomic) IBOutlet UILabel *tweetContent;
@property (weak,nonatomic) IBOutlet UIImageView *tweetUserImage;
@property (weak, nonatomic) IBOutlet UIButton *retweetB;

@end
