//
//  RightTabbleView.h
//  音乐播放
//
//  Created by 曾经 on 16/4/12.
//  Copyright © 2016年 sandy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Music.h"

@protocol RightTabbleViewDelegate <NSObject>

- (void)selcetMusic:(NSInteger *)music;

@end
@interface RightTabbleView : UITableView
@property (nonatomic, assign) id <RightTabbleViewDelegate> rightDelegate;
@end
