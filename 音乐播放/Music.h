//
//  Music.h
//  音乐播放
//
//  Created by 曾经 on 16/4/12.
//  Copyright © 2016年 sandy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Music : NSObject {
    NSString *name;
    NSString *type;
}
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *type;

- (id)initWithName:(NSString *)_name andType:(NSString *)_type;

@end