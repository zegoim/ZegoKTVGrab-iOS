//
//  KTVSoundConfigSliderView.h
//  GoChat
//
//  Created by Vic on 2022/2/17.
//  Copyright © 2022 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Title 和 Slider
 */
@interface GBSliderView : UIView

/**
 * 是否可用
 */
@property (nonatomic, assign) BOOL enable;

/**
 * Slider 值变化回调
 * @param value 值
 * @param manual 是否通过手动操作滑块改变 Slider 的值. YES 则是, NO 则是通过代码改变 Slider 的值
 */
@property (nonatomic, strong) void(^valueUpdateBlock)(CGFloat value, BOOL manual);

/**
 * 初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                       minVal:(CGFloat)minVal
                       maxVal:(CGFloat)maxVal
                   defaultVal:(CGFloat)defaultVal;

- (void)setValue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
