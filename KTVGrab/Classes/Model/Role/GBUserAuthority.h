//
//  GBUserRoleAuthority.h
//  KTVGrab
//
//  Created by Vic on 2022/4/21.
//

#import <Foundation/Foundation.h>
#import "GBEnums.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 不同角色的用户有不同的权限
 * 例如观众不具备玩家所拥有的大部分权限
 */
@interface GBUserAuthority : NSObject

/**
 * 是否允许推流
 */
@property (nonatomic, assign, readonly) BOOL canPublishStream;

/**
 * 是否允许下载歌曲资源
 */
@property (nonatomic, assign, readonly) BOOL canDownloadSong;

/**
 * 是否允许下载歌词
 */
@property (nonatomic, assign, readonly) BOOL canDownloadLyric;

/**
 * 是否允许下载音高线
 */
@property (nonatomic, assign, readonly) BOOL canDownloadPitch;

/**
 * 是否允许抢唱
 */
@property (nonatomic, assign, readonly) BOOL canGrab;

/**
 * 是否可以看到自己本轮战绩
 */
@property (nonatomic, assign, readonly) BOOL canSeeRoundGrade;

/**
 * 是否可以操作麦克风开闭
 */
@property (nonatomic, assign, readonly) BOOL canOperateMicrophone;

/**
 * 是否可以操作音频设置
 */
@property (nonatomic, assign, readonly) BOOL canOperateAudioConfig;

/**
 * 根据用户角色进行初始化
 */
- (instancetype)initWithRoleType:(GBUserRoleType)roleType;

@end

NS_ASSUME_NONNULL_END
