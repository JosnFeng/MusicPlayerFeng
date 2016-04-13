//
//  MusicTableViewController.m
//  音乐播放
//
//  Created by 曾经 on 16/4/12.
//  Copyright © 2016年 sandy. All rights reserved.
//

#import "MusicTableViewController.h"
//#import "RightTableViewController.h"
#import "RightTabbleView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+Scale.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kWidth 30
@interface MusicTableViewController () <RightTabbleViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    AVAudioPlayer *audioPlayer;
    NSMutableArray *musicArray;
    BOOL isPlay;
    BOOL isCircle;
    BOOL musicTableViewHidden;
    float tempVolume;
    Music *currentMusic;
    NSMutableArray *timeArray;
    NSMutableDictionary *LRCDictionary;
    NSUInteger lrcLineNumber;
    NSUInteger musicArrayNumber;
}
@property (nonatomic, strong) UIImageView *bgImage;

@property (nonatomic, strong) UISlider *soundSlider;
@property (nonatomic, strong) UISlider *playSlider;

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, strong) UIButton *cicleBtn;
@property (nonatomic, strong) UIButton *aboveBtn;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *listBtn;

@property (nonatomic, strong) UITableView *musicTableView;
@property (nonatomic, strong) RightTabbleView *rightView;
@end

@implementation MusicTableViewController
//@synthesize soundSlider, progressSlider, playBtn, circleBtn, currentTimeLabel, totalTimeLabel, musicTableView, musicArray;

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubviews];
    [self initMusicSetting];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods 
- (void)initSubviews {
    self.title = @"WLZ的播放器";
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.bgImage];
    [self.bgImage addSubview:self.soundSlider];
    [self.bgImage addSubview:self.playSlider];
    [self.bgImage addSubview:self.musicTableView];
    [self.bgImage addSubview:self.rightView];
    [self.bgImage addSubview:self.currentTimeLabel];
    [self.bgImage addSubview:self.totalTimeLabel];
    [self.bgImage addSubview:self.cicleBtn];
    [self.bgImage addSubview:self.aboveBtn];
    [self.bgImage addSubview:self.playBtn];
    [self.bgImage addSubview:self.nextBtn];
    [self.bgImage addSubview:self.listBtn];
}
- (void)initMusicSetting {
//    musicArrayNumber = 1;
    
    isPlay = YES;
    isCircle = YES;
    //初始化要加载的曲目
    [self initDate];
    musicArrayNumber = 0;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[musicArray[musicArrayNumber] name] ofType:@"mp3"]] error:nil];
    currentMusic = musicArray[musicArrayNumber];
    
    
    //初始化音量和精度条
    audioPlayer.volume = 0.1;
    self.soundSlider.value = audioPlayer.volume;
    
    
    //初始化歌词词典
    timeArray = [[NSMutableArray alloc] initWithCapacity:10];
    LRCDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    [self initLRC];
    //设置监控 每秒刷新一次时间
    [NSTimer scheduledTimerWithTimeInterval:0.1f
                                     target:self
                                   selector:@selector(showTime)
                                   userInfo:nil
                                    repeats:YES];
}
#pragma mark 0.1秒一次更新 播放时间 播放进度条 歌词 歌曲 自动播放下一首
- (void)showTime {
    //动态更新进度条时间
    if ((int)audioPlayer.currentTime % 60 < 10) {
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%d:0%d",(int)audioPlayer.currentTime / 60, (int)audioPlayer.currentTime % 60];
    } else {
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%d:%d",(int)audioPlayer.currentTime / 60, (int)audioPlayer.currentTime % 60];
    }
    //
    if ((int)audioPlayer.duration % 60 < 10) {
        self.totalTimeLabel.text = [NSString stringWithFormat:@"%d:0%d",(int)audioPlayer.duration / 60, (int)audioPlayer.duration % 60];
    } else {
        self.totalTimeLabel.text = [NSString stringWithFormat:@"%d:%d",(int)audioPlayer.duration / 60, (int)audioPlayer.duration % 60];
    }
    self.playSlider.value = audioPlayer.currentTime / audioPlayer.duration;
    
    [self displaySondWord:audioPlayer.currentTime];//调用歌词函数
    
//     NSLog(@"%f",self.playSlider.value);
    //如果播放完，调用自动播放下一首
    if (audioPlayer.isPlaying == YES) {
        [self autoPlay];
    }
    
    
}
#pragma mark 自动进入下一首
- (void)autoPlay {
    //判断是否允许循环播放
    if (isCircle == YES) {
        if (musicArrayNumber == musicArray.count - 1) {
            musicArrayNumber = -1;
        }
        musicArrayNumber++;
        
        [self updatePlayerSetting];
        
    } else {//随机播放
        musicArrayNumber = arc4random() % 3;
        [self updatePlayerSetting];
//        [audioPlayer play];
//        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
//        isPlay = NO;
    }
}
//更新播放器设置
- (void)updatePlayerSetting {
    //更新播放按钮状态
    [self.playBtn setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    isPlay = NO;
    
    //更新曲目
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[musicArray[musicArrayNumber] name] ofType:@"mp3"]] error:nil];
    currentMusic = musicArray[musicArrayNumber];
    //更新音量
    audioPlayer.volume = self.soundSlider.value;
    //重新载入歌词词典
    timeArray = [[NSMutableArray alloc] initWithCapacity:10];
    LRCDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    [self initLRC];
    
    [audioPlayer play];
}
#pragma mark 动态显示歌词
- (void)displaySondWord:(NSUInteger)time {
    //    NSLog(@"time = %u",time);
    for (int i = 0; i < [timeArray count]; i++) {
        
        NSArray *array = [timeArray[i] componentsSeparatedByString:@":"];//把时间转换成秒
        NSUInteger currentTime = [array[0] intValue] * 60 + [array[1] intValue];
        if (i == [timeArray count]-1) {
            //求最后一句歌词的时间点
            NSArray *array1 = [timeArray[timeArray.count-1] componentsSeparatedByString:@":"];
            NSUInteger currentTime1 = [array1[0] intValue] * 60 + [array1[1] intValue];
            if (time > currentTime1) {
                [self updateLrcTableView:i];
                break;
            }
        } else {
            //求出第一句的时间点，在第一句显示前的时间内一直加载第一句
            NSArray *array2 = [timeArray[0] componentsSeparatedByString:@":"];
            NSUInteger currentTime2 = [array2[0] intValue] * 60 + [array2[1] intValue];
            if (time < currentTime2) {
                [self updateLrcTableView:0];
                //                NSLog(@"马上到第一句");
                break;
            }
            //求出下一步的歌词时间点，然后计算区间
            NSArray *array3 = [timeArray[i+1] componentsSeparatedByString:@":"];
            NSUInteger currentTime3 = [array3[0] intValue] * 60 + [array3[1] intValue];
            if (time >= currentTime && time <= currentTime3) {
                [self updateLrcTableView:i];
                break;
            }
            
        }
    }
}
#pragma mark 动态更新歌词表歌词
- (void)updateLrcTableView:(NSUInteger)lineNumber {
    //    NSLog(@"lrc = %@", [LRCDictionary objectForKey:[timeArray objectAtIndex:lineNumber]]);
    //重新载入 歌词列表lrcTabView
    lrcLineNumber = lineNumber;
    [self.musicTableView reloadData];
    //使被选中的行移到中间
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lineNumber inSection:0];
    [self.musicTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    //    NSLog(@"%i",lineNumber);
}
#pragma mark - music setting
- (void)initDate {
    Music *music1 = [[Music alloc] initWithName:@"梁静茹-偶阵雨" andType:@"mp3"];
    Music *music2 = [[Music alloc] initWithName:@"林俊杰-背对背拥抱" andType:@"mp3"];
    Music *music3 = [[Music alloc] initWithName:@"情非得已" andType:@"mp3"];
    //    Music *music4 = [[Music alloc] initWithName:@"张宇-雨一直下" andType:@"mp3"];
    //    Music *music5 = [[Music alloc] initWithName:@"张学友-吻别" andType:@"mp3"];
    musicArray = [[NSMutableArray alloc]initWithCapacity:5];
    [musicArray addObject:music1];
    [musicArray addObject:music2];
    [musicArray addObject:music3];
}
#pragma mark 得到歌词
- (void)initLRC {
    NSString *LRCPath = [[NSBundle mainBundle] pathForResource:[musicArray[musicArrayNumber] name] ofType:@"lrc"];
    NSString *contentStr = [NSString stringWithContentsOfFile:LRCPath encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"contentStr = %@",contentStr);
    NSArray *array = [contentStr componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [array count]; i++) {
        NSString *linStr = [array objectAtIndex:i];
        NSArray *lineArray = [linStr componentsSeparatedByString:@"]"];
        if ([lineArray[0] length] > 8) {
            NSString *str1 = [linStr substringWithRange:NSMakeRange(3, 1)];
            NSString *str2 = [linStr substringWithRange:NSMakeRange(6, 1)];
            if ([str1 isEqualToString:@":"] && [str2 isEqualToString:@"."]) {
                NSString *lrcStr = [lineArray objectAtIndex:1];
                NSString *timeStr = [[lineArray objectAtIndex:0] substringWithRange:NSMakeRange(1, 5)];//分割区间求歌词时间
                //把时间 和 歌词 加入词典
                [LRCDictionary setObject:lrcStr forKey:timeStr];
                [timeArray addObject:timeStr];//timeArray的count就是行数
            }
        }
    }
}
#pragma mark - setters and getters
- (UIImageView *)bgImage {
    if (!_bgImage) {
        _bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
        _bgImage.image = [UIImage imageNamed:@"wlz.JPG"];
        _bgImage.userInteractionEnabled = YES;
    }
    return _bgImage;
}
- (UISlider *)soundSlider {
    if (!_soundSlider) {
        _soundSlider = [[UISlider alloc] initWithFrame:CGRectMake(-30, 20, kScreenWidth + 60, 20)];
//        _soundSlider.backgroundColor = [UIColor redColor];
        [_soundSlider setThumbImage:[UIImage imageNamed:@"soundSlider"]  forState:(UIControlStateNormal)];
        [_soundSlider addTarget:self action:@selector(handleSound:) forControlEvents:(UIControlEventTouchUpInside)];
        _soundSlider.minimumValue = 0.0;
        _soundSlider.maximumValue = 1.0;
    }
    return _soundSlider;
}
- (UITableView *)musicTableView {
    if (!_musicTableView) {
        _musicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.soundSlider.bottom + 10, kScreenWidth, 400)];
        _musicTableView.backgroundColor = [UIColor clearColor];
        _musicTableView.dataSource = self;
        _musicTableView.delegate = self;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMiss)];
        [_musicTableView addGestureRecognizer:tap];
    }
    return _musicTableView;
}
- (RightTabbleView *)rightView {
    if (!_rightView) {
        _rightView = [[RightTabbleView alloc] initWithFrame:CGRectMake(self.musicTableView.right, self.musicTableView.top, 250, self.musicTableView.height) style:(UITableViewStylePlain)];
//        _rightView.backgroundColor = [UIColor redColor];
        _rightView.rightDelegate = self;
    }
    return _rightView;
}
- (UISlider *)playSlider {
    if (!_playSlider) {
        _playSlider = [[UISlider alloc] initWithFrame:CGRectMake(-30, self.musicTableView.bottom + 10, kScreenWidth + 60, 10)];
//        _playSlider.backgroundColor = [UIColor redColor];
        [_playSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small"]  forState:(UIControlStateNormal)];
        [_playSlider addTarget:self action:@selector(handleProgress:) forControlEvents:(UIControlEventTouchUpInside)];
        _playSlider.minimumValue = 0.0;
        _playSlider.maximumValue = 1.0;
        
    }
    return _playSlider;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.playSlider.bottom + 10, 70, 30)];
        _currentTimeLabel.textColor = [UIColor whiteColor];
//        _currentTimeLabel.backgroundColor = [UIColor redColor];
    }
    return _currentTimeLabel;
}
- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 70 - 10, self.currentTimeLabel.top, 70, 30)];
        _totalTimeLabel.textAlignment = NSTextAlignmentRight;
        _totalTimeLabel.textColor = [UIColor whiteColor];
//        _totalTimeLabel.backgroundColor = [UIColor redColor];
    }
    return _totalTimeLabel;
}

- (UIButton *)cicleBtn {
    if (!_cicleBtn) {
        _cicleBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        _cicleBtn.backgroundColor = [UIColor redColor];
        _cicleBtn.frame = CGRectMake(10, self.currentTimeLabel.bottom + 10, kWidth, kWidth);
        [_cicleBtn setImage:[UIImage imageNamed:@"circleOpen"] forState:(UIControlStateNormal)];
        [_cicleBtn addTarget:self action:@selector(handleSelcetMode:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _cicleBtn;
}
- (UIButton *)aboveBtn {
    if (!_aboveBtn) {
        _aboveBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        _aboveBtn.backgroundColor = [UIColor redColor];
        _aboveBtn.frame = CGRectMake(self.cicleBtn.right + 40, self.cicleBtn.top, kWidth, kWidth);
        [_aboveBtn setImage:[UIImage imageNamed:@"aboveMusic"] forState:(UIControlStateNormal)];
        [_aboveBtn addTarget:self action:@selector(handleAbove:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _aboveBtn;
}
- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        _playBtn.backgroundColor = [UIColor redColor];
        _playBtn.frame = CGRectMake(self.aboveBtn.right + 40, self.cicleBtn.top - 5, kWidth + 10, kWidth + 10);
        [_playBtn setImage:[UIImage imageNamed:@"play"] forState:(UIControlStateNormal)];
        [_playBtn addTarget:self action:@selector(handlePlayOrPause:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _playBtn;

}
- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        _nextBtn.backgroundColor = [UIColor redColor];
        _nextBtn.frame = CGRectMake(self.playBtn.right + 40, self.cicleBtn.top, kWidth, kWidth);
        [_nextBtn setImage:[UIImage imageNamed:@"nextMusic"] forState:(UIControlStateNormal)];
        [_nextBtn addTarget:self action:@selector(handleNext:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _nextBtn;
}
- (UIButton *)listBtn {
    if (!_listBtn) {
        _listBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        _listBtn.backgroundColor = [UIColor redColor];
        _listBtn.frame = CGRectMake(self.nextBtn.right + 40, self.nextBtn.top, kWidth, kWidth);
        [_listBtn setImage:[UIImage imageNamed:@"menu"] forState:(UIControlStateNormal)];
        [_listBtn addTarget:self action:@selector(handleList:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _listBtn;

}
#pragma mark - event prense
//上一曲
- (void)handleAbove:(UIButton *)sender {
    if (musicArrayNumber == 0) {
        musicArrayNumber = musicArray.count;
    }
    musicArrayNumber --;
    
    [self updatePlayerSetting];

}
//下一曲
- (void)handleNext:(UIButton *)sender {
    if (musicArrayNumber == musicArray.count - 1) {
        musicArrayNumber = -1;
    }
    musicArrayNumber ++;
    
    [self updatePlayerSetting];
}
//播放
- (void)handlePlayOrPause:(UIButton *)sender {
//    sender.selected = !sender.selected;
    if (isPlay) {
        [_playBtn setImage:[UIImage imageNamed:@"pause"] forState:(UIControlStateNormal)];
//        isPlay = YES;
        [audioPlayer play];
        isPlay = NO;
    } else {
       [_playBtn setImage:[UIImage imageNamed:@"play"] forState:(UIControlStateNormal)];
        isPlay = YES;
        [audioPlayer pause];
    }
}
//播放模式
- (void)handleSelcetMode:(UIButton *)sender {
//    sender.selected = !sender.selected;
    if (isCircle) {
         [_cicleBtn setImage:[UIImage imageNamed:@"randomOpen"] forState:(UIControlStateNormal)];
        isCircle = NO;
    } else {
      [_cicleBtn setImage:[UIImage imageNamed:@"circleOpen"] forState:(UIControlStateNormal)];
        isCircle = YES;
    }
}
//菜单
- (void)handleList:(UIButton *)sender {
    sender.selected = !sender.selected;
    [UIView animateWithDuration:1 animations:^{
        CGRect selfViewFrame = self.view.frame;
        selfViewFrame.origin.x = sender.selected ?  self.musicTableView.right - 200 :  self.musicTableView.right;
        self.rightView.frame = selfViewFrame;
    } completion:^(BOOL finished) {
//        [super willMoveToParentViewController:parent];
    }];

}

- (void)handleSound:(UISlider *)sender {
    audioPlayer.volume = self.soundSlider.value;

}
- (void)handleProgress:(UISlider *)sender {
    audioPlayer.currentTime = self.playSlider.value * audioPlayer.duration;
//    [self initLRC];

}
- (void)handleMiss {
    [UIView animateWithDuration:1 animations:^{
        CGRect selfViewFrame = self.view.frame;
        selfViewFrame.origin.x = self.musicTableView.right;
        self.rightView.frame = selfViewFrame;
    } completion:^(BOOL finished) {
        //        [super willMoveToParentViewController:parent];
    }];
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return timeArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LRCCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//该表格选中后没有颜色
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.row == lrcLineNumber) {
        cell.textLabel.text = LRCDictionary[timeArray[indexPath.row]];
//        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        cell.textLabel.textColor = [UIColor yellowColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    } else {
        cell.textLabel.text = LRCDictionary[timeArray[indexPath.row]];
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//        cell.textLabel.textColor = [UIColor yellowColor];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    //        cell.textLabel.textColor = [UIColor blackColor];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    //        [cell.contentView addSubview:lable];//往列表视图里加 label视图，然后自行布局
    return cell;
}
#pragma mark - custom delegate
- (void)selcetMusic:(NSInteger *)music {
    musicArrayNumber = music;
    [self updatePlayerSetting];
    [self handleMiss];
}
@end




