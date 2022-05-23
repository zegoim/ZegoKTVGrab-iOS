//
//  GBOperateMicAPI.h
//  KTVGrab
//
//  Created by Vic on 2022/4/12.
//

#import "GBBaseAuthRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBOperateMicAPI : GBBaseAuthRequest

/// 房间 ID
@property (nonatomic, copy) NSString *roomID;

/// 麦位序号
@property (nonatomic, assign) NSInteger micIndex;

/// 麦克风状态. 1-关闭, 2-开启
@property (nonatomic, assign) NSInteger micState;

@end

NS_ASSUME_NONNULL_END
