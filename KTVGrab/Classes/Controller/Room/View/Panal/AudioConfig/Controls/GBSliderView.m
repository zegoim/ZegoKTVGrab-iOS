//
//  KTVSoundConfigSliderView.m
//  GoChat
//
//  Created by Vic on 2022/2/17.
//  Copyright © 2022 zego. All rights reserved.
//

#import "GBSliderView.h"
#import "GBSlider.h"
#import "GBAudioTitleLabel.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import "GBImage.h"
#import <MessageThrottle/MessageThrottle.h>

@interface GBSliderView ()

@property (nonatomic, strong) GBAudioTitleLabel *titleLabel;
@property (nonatomic, strong) GBSlider *slider;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CGFloat minVal;
@property (nonatomic, assign) CGFloat maxVal;
@property (nonatomic, assign) CGFloat defaultVal;

@end

@implementation GBSliderView

- (instancetype)initWithFrame:(CGRect)frame
                        title:(nonnull NSString *)title
                       minVal:(CGFloat)minVal
                       maxVal:(CGFloat)maxVal
                   defaultVal:(CGFloat)defaultVal {
  if (self = [super initWithFrame:frame]) {
    _title = title;
    _minVal = minVal;
    _maxVal = maxVal;
    _defaultVal = defaultVal;
    
    [self setupUI];
    
    //对 Slider 的值回调方法调用进行限频
    __unused MTRule *rule = [self mt_limitSelector:@selector(calloutToUpdateSliderValue:manual:)
                                   oncePerDuration:0.5
                                         usingMode:MTPerformModeLast
                                    onMessageQueue:dispatch_get_main_queue()];
  }
  return self;
}

- (void)setupUI {
  
  self.backgroundColor = UIColor.clearColor;
  self.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self setupSubviews];
}

- (void)setupSubviews {
  GBAudioTitleLabel *titleLabel = [[GBAudioTitleLabel alloc] init];
  titleLabel.text = self.title;
  self.titleLabel = titleLabel;
  
  GBSlider *slider = [[GBSlider alloc] init];
  slider.minimumTrackTintColor = [UIColor colorWithHexString:@"#FFFFFF"];
  slider.maximumTrackTintColor = [UIColor colorWithHexString:@"#220848"];
  [slider setThumbImage:[GBImage imageNamed:@"ktv_slider_thumb"] forState:UIControlStateNormal];
  slider.minimumValue = self.minVal;
  slider.maximumValue = self.maxVal;
  [slider setValue:self.defaultVal animated:YES];
  [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  self.slider = slider;
  
  [self addSubview:titleLabel];
  [self addSubview:slider];
  
  [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(16);
    make.top.equalTo(self).offset(8);
  }];
  
  [slider mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(titleLabel);
    make.right.equalTo(self).inset(8);
    make.top.equalTo(titleLabel.mas_bottom);
  }];
}

- (void)setEnable:(BOOL)enable {
  _enable = enable;
  
  CGFloat alpha = (enable ? 1 : 0.5);
  self.titleLabel.alpha = alpha;
  self.slider.alpha = alpha;
  self.slider.userInteractionEnabled = enable;
}

- (void)setValue:(CGFloat)value {
  self.slider.value = value;
  [self calloutToUpdateSliderValue:value manual:NO];
}

- (void)setValueUpdateBlock:(void (^)(CGFloat, BOOL))valueUpdateBlock {
  _valueUpdateBlock = valueUpdateBlock;
  [self calloutToUpdateSliderValue:self.slider.value manual:NO];
}

- (void)sliderValueChanged:(UISlider *)slider {
  [self calloutToUpdateSliderValue:slider.value manual:YES];
}

- (void)calloutToUpdateSliderValue:(CGFloat)value manual:(BOOL)flag {
  self.valueUpdateBlock(value, flag);
}

@end
