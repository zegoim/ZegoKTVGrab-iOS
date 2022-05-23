//
//  ZGKTVGuestCell.m
//  GoChat
//
//  Created by Vic on 2021/10/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import "GBSeatCell.h"
#import "GBNetQualityModel.h"

#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import "GBImage.h"

#import "GBSeatAvatarContainerView.h"
#import "GBSeatBottomView.h"
#import "GBSoundLevelView.h"
#import "GBSeatQualityView.h"

@interface GBSeatCell ()

@property (nonatomic, strong) GBSeatAvatarContainerView *avatarContainerView;
@property (nonatomic, strong) GBSeatBottomView *bottomView;
@property (nonatomic, strong) GBSeatQualityView *qualityView;

@property (nonatomic, copy) NSDictionary *netImageNameTable;

@end

@implementation GBSeatCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  [self setupSubviews];
}

- (void)setupSubviews {
  UIView *contentView = self.contentView;
  
  [contentView addSubview:self.avatarContainerView];
  [contentView addSubview:self.bottomView];
  [contentView addSubview:self.qualityView];
}

- (void)updateConstraints {
  [self.avatarContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(60);
    make.centerX.equalTo(self);
  }];
  
  [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.avatarContainerView.mas_bottom);
    make.left.greaterThanOrEqualTo(self.contentView);
    make.right.lessThanOrEqualTo(self.contentView);
    make.height.mas_equalTo(13);
    make.centerX.equalTo(self.contentView);
    make.bottom.equalTo(self.contentView).inset(3);
  }];
  
  [self.qualityView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView).offset(2);
    make.right.equalTo(self.contentView).inset(2);
    make.top.bottom.equalTo(self.avatarContainerView);
  }];
  
  [super updateConstraints];
}

#pragma mark - View
- (GBSeatAvatarContainerView *)avatarContainerView {
  if (!_avatarContainerView) {
    _avatarContainerView = [[GBSeatAvatarContainerView alloc] init];
    [self addSubview:_avatarContainerView];
  }
  return _avatarContainerView;
}

- (GBSeatBottomView *)bottomView {
  if (!_bottomView) {
    _bottomView = [[GBSeatBottomView alloc] init];
  }
  return _bottomView;
}

- (GBSeatQualityView *)qualityView {
  if (!_qualityView) {
    _qualityView = [[GBSeatQualityView alloc] init];
  }
  return _qualityView;
}

#pragma mark - Setter & Getter
- (void)setCellVM:(GBSeatCellVM *)cellVM {
  _cellVM = cellVM;
  [self.avatarContainerView setCellVM:cellVM];
  [self.bottomView setText:cellVM.displayName];
  [self updateNetQualityWithCellVM:cellVM];
}

- (NSDictionary *)netImageNameTable {
  if (!_netImageNameTable) {
    _netImageNameTable = @{
      @(GBNetQualityUnknown)  : @"ktv_network_testing",
      @(GBNetQualityBad)      : @"ktv_network_bad",
      @(GBNetQualityMedium)   : @"ktv_network_normal",
      @(GBNetQualityGood)     : @"ktv_network_best",
    };
  }
  return _netImageNameTable;
}

#pragma mark - Private
- (void)updateNetQualityWithCellVM:(GBSeatCellVM *)cellVM {
  [self updateRealDataWithCellVM:cellVM];
  [self updateNetIndicatorWithCellVM:cellVM];
}

- (void)updateNetIndicatorWithCellVM:(GBSeatCellVM *)cellVM {
  if (!cellVM.seatInfo.hasStream) {
    [self.bottomView setImage:nil];
    return;
  }
  if (!cellVM.seatInfo.netQuality) {
    [self.bottomView setImage:nil]; //网络图标
  }else {
    [self updateNetQualityLevel:cellVM.qualityLevel];
  }
}

- (void)updateRealDataWithCellVM:(GBSeatCellVM *)cellVM {
  if (cellVM.empty) {
    self.qualityView.hidden = YES;
    [self.qualityView resetAllValues];
    return;
  }
  if (cellVM.showTestData) {
    self.qualityView.hidden = NO;
    [self updateTestDataWithNetQuality:cellVM.netQuality];
  }else {
    self.qualityView.hidden = YES;
    [self.qualityView resetAllValues];
  }
}

- (void)updateNetQualityLevel:(GBNetQuality)quality {
  NSString *imageName = self.netImageNameTable[@(quality)];
  UIImage *img = [GBImage imageNamed:imageName];
  [self.bottomView setImage:img];
}

- (void)updateTestDataWithNetQuality:(GBNetQualityModel *)netQuality {
  [self.qualityView setNetQuality:netQuality];
}

@end
