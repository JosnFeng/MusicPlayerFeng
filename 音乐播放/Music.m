//
//  Music.m
//  音乐播放
//
//  Created by 曾经 on 16/4/12.
//  Copyright © 2016年 sandy. All rights reserved.
//

#import "Music.h"



@implementation Music

@synthesize name, type;

- (id)initWithName:(NSString *)_name andType:(NSString *)_type; {
    if (self = [super init]) {
        self.name = _name;
        self.type = _type;
    }
    return self;
}

@end
