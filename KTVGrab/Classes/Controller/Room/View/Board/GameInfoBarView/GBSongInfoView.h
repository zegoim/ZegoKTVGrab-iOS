//
//  ZGKTVSongBasicInfoView.h
//  GoChat
//
//  Created by Vic on 2021/12/5.
//  Copyright © 2021 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GBSong;

NS_ASSUME_NONNULL_BEGIN

/// Has intrinsic size
@interface GBSongInfoView : UIView

@property (nonatomic, strong) GBSong *song;
/// 当前播放时间, 单位为 ms
@property (nonatomic, assign) NSInteger progress;
/// 歌曲进度是否可见
@property (nonatomic, assign) BOOL progressVisible;

@end

NS_ASSUME_NONNULL_END
