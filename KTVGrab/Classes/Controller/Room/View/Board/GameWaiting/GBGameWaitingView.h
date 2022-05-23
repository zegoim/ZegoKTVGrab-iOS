//
//  GBGameWaitingView.h
//  AFNetworking
//
//  Created by Vic on 2022/2/23.
//

#import <UIKit/UIKit.h>
#import "GBEnums.h"

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic size
@interface GBGameWaitingView : UIView

@property (nonatomic, assign) GBUserRoleType role;

@property (nonatomic, strong) void(^onClickStartGameButton)(void);

@end

NS_ASSUME_NONNULL_END
