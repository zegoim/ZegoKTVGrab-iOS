//
//  GBUserGrabbedInfoView.h
//  KTVGrab
//
//  Created by Vic on 2022/2/23.
//

#import <UIKit/UIKit.h>

@class GBUser;

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic size
/// 用于展示 xxx 已经抢到麦了
@interface GBUserGrabbedInfoView : UIView

- (void)setGrabUser:(GBUser *)user;

@end

NS_ASSUME_NONNULL_END
