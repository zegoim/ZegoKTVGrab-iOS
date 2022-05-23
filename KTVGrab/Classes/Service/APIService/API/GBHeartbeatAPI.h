//
//  GBHeartbeatAPI.h
//  KTVGrab
//
//  Created by Vic on 2022/3/15.
//

#import "GBBaseAuthRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBHeartbeatAPI : GBBaseAuthRequest

/// 房间 ID
@property (nonatomic, strong) NSString *roomID;

@end

NS_ASSUME_NONNULL_END
