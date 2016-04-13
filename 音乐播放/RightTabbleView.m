//
//  RightTabbleView.m
//  音乐播放
//
//  Created by 曾经 on 16/4/12.
//  Copyright © 2016年 sandy. All rights reserved.
//

#import "RightTabbleView.h"
@interface RightTabbleView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@end
@implementation RightTabbleView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.alpha = 0.5;
        [self initDate];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}
#pragma mark 载入歌曲数组
- (void)initDate {
    Music *music1 = [[Music alloc] initWithName:@"梁静茹-偶阵雨" andType:@"mp3"];
    Music *music2 = [[Music alloc] initWithName:@"林俊杰-背对背拥抱" andType:@"mp3"];
    Music *music3 = [[Music alloc] initWithName:@"情非得已" andType:@"mp3"];
    //    Music *music4 = [[Music alloc] initWithName:@"张宇-雨一直下" andType:@"mp3"];
    //    Music *music5 = [[Music alloc] initWithName:@"张学友-吻别" andType:@"mp3"];
//    musicArray = [[NSMutableArray alloc]initWithCapacity:5];
    [self.data addObject:music1];
    [self.data addObject:music2];
    [self.data addObject:music3];
    //    [musicArray addObject:music4];
    //    [musicArray addObject:music5];
    
    
    
}


#pragma mark - UITableViewDelegate
- (NSMutableArray *)data {
    if (!_data) {
        self.data = [NSMutableArray new];
    }
    return _data;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    Music *music = self.data[indexPath.row];
    cell.textLabel.text = music.name;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     Music *music = self.data[indexPath.row];
    if ([self.rightDelegate respondsToSelector:@selector(selcetMusic:)]) {
        [self.rightDelegate selcetMusic:indexPath.row];
    }
}
@end
