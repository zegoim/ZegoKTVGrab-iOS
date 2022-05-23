//
//  GBUploadScoreAPI.h
//  KTVGrab
//
//  Created by Vic on 2022/4/8.
//

#import "GBBaseAuthRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBUploadScoreAPI : GBBaseAuthRequest

/// 房间 ID
@property (nonatomic, copy) NSString *roomID;

/// 歌曲 ID
@property (nonatomic, copy) NSString *songID;

/// 分数
@property (nonatomic, assign) NSUInteger score;

@end

NS_ASSUME_NONNULL_END
