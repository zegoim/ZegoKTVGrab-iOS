//
//  GBSongsReadyAPI.h
//  KTVGrab
//
//  Created by Vic on 2022/3/16.
//

#import "GBBaseAuthRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBSongsReadyAPI : GBBaseAuthRequest

/// 房间 ID
@property (nonatomic, copy) NSString *roomID;

/// 轮次
@property (nonatomic, assign) NSUInteger round;

/// 不可用歌曲的后台唯一 ID 数组
@property (nonatomic, copy) NSArray<NSString *> *invalidUniqueIDs;

@end

NS_ASSUME_NONNULL_END
