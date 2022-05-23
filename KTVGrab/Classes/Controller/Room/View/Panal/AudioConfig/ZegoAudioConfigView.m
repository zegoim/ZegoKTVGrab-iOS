//
//  ZegoAudioConfigView.m
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/18.
//

#import "ZegoAudioConfigView.h"
#import "GBSliderView.h"
#import "GBAudioSwitchView.h"
#import "GBAudioTitleLabel.h"
#import "GBAudioReverbSelectView.h"

#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "GBImage.h"
#import "GBExpress.h"
#import "GBRoomInfo.h"
#import <GoKit/GoUIKit.h>

@interface ZegoAudioConfigView () <UIScrollViewDelegate, GBAudioReverbListener>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollContentView;

@property (nonatomic, strong) GBAudioSwitchView *iemSwitch;
@property (nonatomic,  copy ) NSArray<GBSliderView *> *sliderViews;
@property (nonatomic, strong) GBSliderView *iemSlider;
@property (nonatomic, strong) GBSliderView *mediaPlayerVolumeSlider;
@property (nonatomic, strong) GBSliderView *voiceVolumeSlider;
@property (nonatomic, strong) GBAudioReverbSelectView *reverbView;

@end

@implementation ZegoAudioConfigView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  [self setupSubviews];
}

- (void)setupSubviews {
  GBAudioTitleLabel *titleLabel = [[GBAudioTitleLabel alloc] init];
  titleLabel.text = @"调音";
  titleLabel.font = [UIFont systemFontOfSize:17];
  
  UIButton *resetButton = [[UIButton alloc] init];
  [resetButton setTitle:@"重置" forState:UIControlStateNormal];
  [resetButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
  [resetButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
  [resetButton setImage:[GBImage imageNamed:@"ktv_config_reset"] forState:UIControlStateNormal];
  [resetButton addTarget:self action:@selector(resetAudioConfig) forControlEvents:UIControlEventTouchUpInside];
  
  UIScrollView *scrollView = [[UIScrollView alloc] init];
  scrollView.delegate = self;
  scrollView.backgroundColor = UIColor.clearColor;
  self.scrollView = scrollView;
  
  [self addSubview:titleLabel];
  [self addSubview:resetButton];
  [self addSubview:scrollView];
  
  [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self);
    make.left.equalTo(self).offset(15);
  }];
  
  [resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(titleLabel);
    make.right.equalTo(self).inset(15);
    make.size.mas_equalTo(CGSizeMake(40, 17));
  }];
  
  [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self);
    make.top.equalTo(titleLabel.mas_bottom).offset(16);
  }];
  
  [self addSubviewsForScrollView:scrollView];
}

- (void)addSubviewsForScrollView:(UIScrollView *)scrollView {
  UIView *scrollContentView = [[UIView alloc] init];
  self.scrollContentView = scrollContentView;
  
  [scrollView addSubview:scrollContentView];
  [scrollContentView addSubview:self.iemSwitch];
  [scrollContentView addSubview:self.iemSlider];
  [scrollContentView addSubview:self.mediaPlayerVolumeSlider];
  [scrollContentView addSubview:self.voiceVolumeSlider];
  [scrollContentView addSubview:self.reverbView];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat sliderHeight = 52;
  
  [self.scrollContentView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.scrollView);
    make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.bounds), 347));
  }];
  
  [self.iemSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.scrollContentView);
    make.top.equalTo(self.scrollContentView);
    make.height.mas_equalTo(sliderHeight);
  }];
  
  [self.iemSlider mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.scrollContentView);
    make.top.equalTo(self.iemSwitch.mas_bottom);
    make.height.mas_equalTo(sliderHeight);
  }];
  
  [self.mediaPlayerVolumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.scrollContentView);
    make.top.equalTo(self.iemSlider.mas_bottom);
    make.height.mas_equalTo(sliderHeight);
  }];
  
  [self.voiceVolumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.scrollContentView);
    make.top.equalTo(self.mediaPlayerVolumeSlider.mas_bottom);
    make.height.mas_equalTo(sliderHeight);
  }];
  
  [self.reverbView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.voiceVolumeSlider.mas_bottom);
    make.left.right.equalTo(self.scrollContentView);
  }];
}

#pragma mark - View
- (GBAudioSwitchView *)iemSwitch {
  if (!_iemSwitch) {
    GBAudioSwitchView *view = [[GBAudioSwitchView alloc] init];
    view.titleText = @"耳返";
    view.descText = @"需戴上耳机才能感受到效果";
    @weakify(self);
    view.audioSwitchUpdateBlock = ^(BOOL enable) {
      @strongify(self);
      [self.iemSlider setEnable:enable];
      [[GBExpress shared] setIemEnable:enable];
    };
    [view setEnable:NO];
    
    _iemSwitch = view;
  }
  return _iemSwitch;
}

- (GBSliderView *)iemSlider {
  if (!_iemSlider) {
    GBSliderView *slider = [[GBSliderView alloc] initWithFrame:CGRectZero title:@"耳返音量" minVal:0 maxVal:100 defaultVal:[GBExpress shared].iemValue];
    @weakify(self);
    slider.valueUpdateBlock = ^(CGFloat value, BOOL manual) {
      @strongify(self);
      [[GBExpress shared] setIemValue:value];
      if (manual) {
        [self alertAdjustmentIneffectiveIfNecessary];
      }
    };
    _iemSlider = slider;
  }
  return _iemSlider;
}

- (GBSliderView *)mediaPlayerVolumeSlider {
  if (!_mediaPlayerVolumeSlider) {
    GBSliderView *slider = [[GBSliderView alloc] initWithFrame:CGRectZero title:@"伴奏音量" minVal:0 maxVal:100 defaultVal:[GBExpress shared].mediaPlayerVolume];
    @weakify(self);
    slider.valueUpdateBlock = ^(CGFloat value, BOOL manual) {
      @strongify(self);
      [[GBExpress shared] setMediaPlayerVolume:value];
      if (manual) {
        [self alertAdjustmentIneffectiveIfNecessary];
      }
    };
    _mediaPlayerVolumeSlider = slider;
  }
  return _mediaPlayerVolumeSlider;
}

- (GBSliderView *)voiceVolumeSlider {
  if (!_voiceVolumeSlider) {
    GBSliderView *slider = [[GBSliderView alloc] initWithFrame:CGRectZero title:@"人声音量" minVal:0 maxVal:150 defaultVal:[GBExpress shared].voiceCaptureVolume];
    @weakify(self);
    slider.valueUpdateBlock = ^(CGFloat value, BOOL manual) {
      @strongify(self);
      [[GBExpress shared] setVoiceCaptureVolume:value];
      if (manual) {
        [self alertAdjustmentIneffectiveIfNecessary];
      }
    };
    _voiceVolumeSlider = slider;
  }
  return _voiceVolumeSlider;
}

- (GBAudioReverbSelectView *)reverbView {
  if (!_reverbView) {
    _reverbView = [[GBAudioReverbSelectView alloc] init];
    [_reverbView setListener:self];
  }
  return _reverbView;
}

- (NSArray *)sliderViews {
  if (!_sliderViews) {
    _sliderViews = @[
      self.iemSlider,
      self.mediaPlayerVolumeSlider,
      self.voiceVolumeSlider,
    ];
  }
  return _sliderViews;
}

#pragma mark - Action
- (void)resetAudioConfig {
  [self.iemSwitch setEnable:NO];
  [self.iemSlider setValue:50];
  [self.mediaPlayerVolumeSlider setValue:50];
  [self.voiceVolumeSlider setValue:100];
  [self.reverbView setDefaultReverb];
}

- (void)alertAdjustmentIneffectiveIfNecessary {
  BOOL isMyselfHost = [GBUserAccount shared].myself.roleType == GBUserRoleTypeHost;
  BOOL isMeSinging = [[GBUserAccount shared].myself.userID isEqualToString:self.roomInfo.curPlayerID];
  
  if (self.roomInfo.roomState == GBRoomStateGameWaiting) {
    if (isMyselfHost) {
      return;
    }
  }
  else if (self.roomInfo.roomState == GBRoomStateSinging) {
    if (isMeSinging) {
      return;
    }
  }
  
  [self alertSliderIneffective];
}

- (void)alertSliderIneffective {
  [GoNotice showToast:@"调节效果仅在演唱时生效" duration:1 onView:self];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  for (UIView *slider in self.sliderViews) {
    [slider setUserInteractionEnabled:NO];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  for (UIView *slider in self.sliderViews) {
    [slider setUserInteractionEnabled:YES];
  }
}

#pragma mark - GBAudioReverbListener
- (void)onReverbSelectedAtIndex:(NSUInteger)index manual:(BOOL)manual {
  if (manual) {
    [self alertAdjustmentIneffectiveIfNecessary];
  }
}

@end
