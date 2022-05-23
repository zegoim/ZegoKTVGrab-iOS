//
//  GBRipplesLayer.h
//  KTVGrab
//
//  Created by Vic on 2022/3/24.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

/// 水波纹动画 layer
@interface GBRipplesLayer : CAReplicatorLayer

/**
 *  圆圈半径，用来确定圆圈Bounds
 */
@property (nonatomic, assign) CGFloat radius;
/**
 *  涟漪动画持续时间, 默认 1s
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;
/**
 *  涟漪动画边缘颜色, 默认 green color
 */
@property (nonatomic, strong) UIColor *rippleBorderColor;
/**
 *  涟漪动画背景填充颜色, 默认 clear color
 */
@property (nonatomic, strong) UIColor *rippleBackgroundColor;

/**
 *  开启动画
 */
- (void)startAnimation;


@end

NS_ASSUME_NONNULL_END
