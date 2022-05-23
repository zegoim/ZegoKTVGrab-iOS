//
//  GBGrabMicView.h
//  KTVGrab
//
//  Created by Vic on 2022/3/24.
//

#import <UIKit/UIKit.h>
#import "GBTypeDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic size.
/// 抢唱 3.2.1 倒计时 view
@interface GBGrabMicView : UIView

/// 触发抢唱
- (instancetype)initWithGrabDuration:(CGFloat)grabDuration grabTriggerBlock:(GBEmptyBlock)block;


@end

NS_ASSUME_NONNULL_END
