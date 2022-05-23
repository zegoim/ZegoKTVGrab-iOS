//
//  GBSEIModel.h
//  KTVGrab
//
//  Created by Vic on 2022/3/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBSEIModel : NSObject

/**
 * 歌曲 ID
 */
@property (nonatomic, copy) NSString *songID;

/**
 * 用户角色
 */
@property (nonatomic, assign) NSInteger role;

/**
 * 播放器状态
 */
@property (nonatomic, assign) NSUInteger playerState;

/**
 * 播放器进度
 */
@property (nonatomic, assign) NSInteger progress;

/**
 * 歌曲总时长
 */
@property (nonatomic, assign) NSInteger duration;

@end

NS_ASSUME_NONNULL_END
