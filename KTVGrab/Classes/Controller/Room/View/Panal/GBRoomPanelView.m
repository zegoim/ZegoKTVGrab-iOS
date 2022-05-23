//
//  GBRoomPanelView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/9.
//

#import "GBRoomPanelView.h"
#import "GBPanelButton.h"
#import "GBImage.h"
#import <Masonry/Masonry.h>
#import "GBExpress.h"
#import "GBUser.h"
#import "GBUserAuthority.h"
#import <MessageThrottle/MessageThrottle.h>

@interface GBRoomPanelView ()

@property (nonatomic, strong) UIStackView   *panelStackView;
@property (nonatomic, strong) GBPanelButton *micButton;
@property (nonatomic, strong) GBPanelButton *audioConfigButton;
@property (nonatomic, strong) GBPanelButton *realTimeDataButton;

@end

@implementation GBRoomPanelView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setMicEnable:NO];
    [self setAudioConfigVisible:NO];
    
    __unused MTRule *rule = [self mt_limitSelector:@selector(clickPanelItem:selected:)
                                   oncePerDuration:0.5
                                         usingMode:MTPerformModeLast
                                    onMessageQueue:dispatch_get_main_queue()];
    
    __unused MTRule *rule1 = [self mt_limitSelector:@selector(notifyToAlert)
                                    oncePerDuration:0.5
                                          usingMode:MTPerformModeDebounce
                                     onMessageQueue:dispatch_get_main_queue()];
  }
  return self;
}

- (void)updateConstraints {
  [self.panelStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];
  [super updateConstraints];
}

- (UIStackView *)panelStackView {
  if (!_panelStackView) {
    UIStackView *view = [[UIStackView alloc] initWithArrangedSubviews:@[
      self.micButton,
      self.audioConfigButton,
      self.realTimeDataButton
    ]];
    view.axis = UILayoutConstraintAxisHorizontal;
    view.spacing = 14;
    [self addSubview:view];
    _panelStackView = view;
  }
  return _panelStackView;
}

- (GBPanelButton *)micButton {
  if (!_micButton) {
    GBPanelButton *view = [[GBPanelButton alloc] init];
    view.itemType = GBPanelItemTypeMic;
    [view setImage:[GBImage imageNamed:@"ktv_mic_off"] forState:UIControlStateNormal];
    [view setImage:[GBImage imageNamed:@"ktv_mic_on"] forState:UIControlStateSelected];
    [view setTitle:@"麦克风" forState:UIControlStateNormal];
    [view addTarget:self action:@selector(onClickPanelItem:) forControlEvents:UIControlEventTouchUpInside];
    _micButton = view;
  }
  return _micButton;
}

- (GBPanelButton *)audioConfigButton {
  if (!_audioConfigButton) {
    GBPanelButton *view = [[GBPanelButton alloc] init];
    view.itemType = GBPanelItemTypeAudioConfig;
    [view setImage:[GBImage imageNamed:@"ktv_audio_config"] forState:UIControlStateNormal];
    [view setTitle:@"调节" forState:UIControlStateNormal];
    [view addTarget:self action:@selector(onClickPanelItem:) forControlEvents:UIControlEventTouchUpInside];
    _audioConfigButton = view;
  }
  return _audioConfigButton;
}

- (GBPanelButton *)realTimeDataButton {
  if (!_realTimeDataButton) {
    GBPanelButton *view = [[GBPanelButton alloc] init];
    view.itemType = GBPanelItemTypeRealData;
    [view setImage:[GBImage imageNamed:@"ktv_real_data_off"] forState:UIControlStateNormal];
    [view setImage:[GBImage imageNamed:@"ktv_real_data_on"] forState:UIControlStateSelected];
    [view setTitle:@"实时数据" forState:UIControlStateNormal];
    [view addTarget:self action:@selector(onClickPanelItem:) forControlEvents:UIControlEventTouchUpInside];
    _realTimeDataButton = view;
  }
  return _realTimeDataButton;
}

- (void)setMicEnable:(BOOL)visible {
  if (![[[GBUserAccount shared] getMyAuthority] canOperateMicrophone]) {
    self.micButton.hidden = YES;
    return;
  }
  [self.micButton setEnableFlag:visible];
  self.micButton.selected = [GBExpress shared].micEnable;
}

- (void)setAudioConfigVisible:(BOOL)visible {
  if (![[[GBUserAccount shared] getMyAuthority] canOperateAudioConfig]) {
    visible = NO;
  }
  self.audioConfigButton.hidden = !visible;
}

#pragma mark - Action
- (void)onClickPanelItem:(GBPanelButton *)sender {
  GBPanelItemType itemType = sender.itemType;
  if (itemType == GBPanelItemTypeMic) {
    if (!sender.enableFlag) {
      [self notifyToAlert];
      return;
    }
  }
  sender.selected = !sender.isSelected;
  [self clickPanelItem:itemType selected:sender.selected];
}

- (void)clickPanelItem:(GBPanelItemType)type selected:(BOOL)selected {
  if (type == GBPanelItemTypeMic) {
    // selected 为开启麦克风
    self.shouldOpenMicrophone(selected);
  }
  
  else if (type == GBPanelItemTypeAudioConfig) {
    // 打开调节面板
    self.shouldModalAudioConfigPanel();
  }
  
  else if (type == GBPanelItemTypeRealData) {
    // selected 为开启, 反之关闭
    [[NSNotificationCenter defaultCenter] postNotificationName:kGBSeatQualityVisibilityNotificationName object:nil userInfo:@{
      kGBSeatQualityVisibilityNotificationKey : @(selected),
    }];
  }
}

- (void)notifyToAlert {
  self.alertMicIsDisabled();
}

@end
