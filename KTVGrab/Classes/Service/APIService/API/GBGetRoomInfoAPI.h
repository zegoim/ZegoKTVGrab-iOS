//
//  GBGetRoomInfoAPI.h
//  KTVGrab
//
//  Created by Vic on 2022/4/11.
//

#import "GBBaseAuthRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBGetRoomInfoAPI : GBBaseAuthRequest

/// 房间 ID
@property (nonatomic, copy) NSString *roomID;

@end

NS_ASSUME_NONNULL_END
