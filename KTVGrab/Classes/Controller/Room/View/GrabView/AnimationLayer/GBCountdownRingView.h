//
//  GBCountdownRingView.h
//  KTVGrab
//
//  Created by Vic on 2022/3/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBCountdownRingView : UIView

/// 倒计时自然结束
@property (nonatomic, strong) void(^onCountdownRingFinished)(void);

/// 圆环线宽
@property (nonatomic, assign) CGFloat lineWidth;

/// 圆环颜色
@property (nonatomic, strong) UIColor *lineColor;

/// 倒计时动画时长
@property (nonatomic, assign) NSInteger duration;

/// 是否为虚线圆环, 默认 NO
@property (nonatomic, assign) BOOL dashed;

/// 开始倒计时
- (void)start;

/// 停止倒计时
- (void)stop;

@end

NS_ASSUME_NONNULL_END
