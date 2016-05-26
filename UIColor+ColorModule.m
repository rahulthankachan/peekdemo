//
//  UIColor+ColorModule.m
//  peekDemoApp
//
//  Created by Rahul Thankachan on 5/26/16.
//  Copyright © 2016 Rahul Thankachan. All rights reserved.
//

#import "UIColor+ColorModule.h"

#define color(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation UIColor (ColorModule)


+(UIColor*)kColorRow1 {
    return color(48, 146, 250, 0.5);
}

+(UIColor*)kColorRow2 {
    return color(48, 146, 250, 0.1);
}


@end
