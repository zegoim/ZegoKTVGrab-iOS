//
//  GBLoginRoomAPI.h
//  KTVGrab
//
//  Created by Vic on 2022/3/14.
//

#import "GBBaseAuthRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 加入房间
@interface GBJoinRoomAPI : GBBaseAuthRequest

/// 房间 ID
@property (nonatomic, copy) NSString *roomID;

@end

NS_ASSUME_NONNULL_END
