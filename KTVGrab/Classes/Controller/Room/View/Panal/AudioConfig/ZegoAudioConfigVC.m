//
//  ZegoAudioConfigVC.m
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/18.
//

#import "ZegoAudioConfigVC.h"
#import "ZegoAudioConfigView.h"
#import <Masonry/Masonry.h>
#import "GBRoomInfo.h"

@interface ZegoAudioConfigVC ()

@property (nonatomic, strong) ZegoAudioConfigView *configView;

@end

@implementation ZegoAudioConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (CGFloat)presentingHeight {
  CGFloat bottomSafeHeight = 0;
  if (@available(iOS 11.0, *)) {
    bottomSafeHeight = self.view.safeAreaInsets.bottom;
  }
  return 400 + bottomSafeHeight;
}

- (void)setupContentView:(UIView *)contentView {
  [contentView addSubview:self.configView];
  
  [self.configView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(contentView);
  }];
}

- (void)setRoomInfo:(GBRoomInfo *)roomInfo {
  _roomInfo = roomInfo;
  [self.configView setRoomInfo:roomInfo];
}

- (ZegoAudioConfigView *)configView {
  if (!_configView) {
    _configView = [[ZegoAudioConfigView alloc] init];
  }
  return _configView;
}

@end
