//
//  GBRoundResultView.h
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import <UIKit/UIKit.h>

@class GBUser;
@class GBRoundGrade;

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic size
@interface GBRoundResultView : UIView

/// 用户
@property (nonatomic, strong) GBUser *user;

/// 战绩
@property (nonatomic, strong) GBRoundGrade *grade;

/// 是否为观战者模式
@property (nonatomic, assign) BOOL spectatorMode;

/// 是否有下一轮
@property (nonatomic, assign) BOOL hasAnotherRound;

/// 再来一局的触发事件
@property (nonatomic, strong) void(^onClickAnotherRound)(void);

/// 离开房间的触发事件
@property (nonatomic, strong) void(^onClickLeaveRoom)(void);

- (void)setText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
