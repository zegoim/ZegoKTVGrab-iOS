//
//  ZGKTVUserInfoView.h
//  GoChat
//
//  Created by Vic on 2021/10/22.
//  Copyright © 2021 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GBUser;

NS_ASSUME_NONNULL_BEGIN

/// Has intrinsic size
@interface GBRoomInfoView : UIView

- (void)setUser:(GBUser *)user;
- (void)setRoomName:(NSString *)roomSubject;

@end

NS_ASSUME_NONNULL_END
