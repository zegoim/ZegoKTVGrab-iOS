//
//  GBGrabMicAPI.h
//  KTVGrab
//
//  Created by Vic on 2022/3/16.
//

#import "GBBaseAuthRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBGrabMicAPI : GBBaseAuthRequest

/**
 * 房间 ID
 */
@property (nonatomic, copy) NSString *roomID;

/**
 * 待抢唱歌曲位于的轮次
 */
@property (nonatomic, assign) NSInteger round;

/**
 * 待抢唱歌曲在轮次中的 index
 */
@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
