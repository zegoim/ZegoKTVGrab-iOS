//
//  ZGKTVTestDataView.m
//  GoChat
//
//  Created by Vic on 2021/10/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import "GBSeatQualityView.h"
#import <YYKit/YYKit.h>
#import "GBNetQualityModel.h"

@interface GBSeatQualityHorizontalView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dataLabel;

@end

@implementation GBSeatQualityHorizontalView

- (instancetype)init {
  self = [super init];
  if (self) {
    [self resetValue];
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)updateConstraints {
  [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self);
    make.left.equalTo(self).offset(10);
  }];
  
  [self.dataLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self);
    make.right.equalTo(self).inset(10);
  }];
  [super updateConstraints];
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    UILabel *view = [[UILabel alloc] init];
    view.textColor = UIColor.whiteColor;
    view.font = [UIFont systemFontOfSize:9];
    [self addSubview:view];
    _titleLabel = view;
  }
  return _titleLabel;
}

- (UILabel *)dataLabel {
  if (!_dataLabel) {
    UILabel *view = [[UILabel alloc] init];
    view.alpha = 0.8;
    view.textColor = UIColor.whiteColor;
    view.font = [UIFont systemFontOfSize:9];
    view.textAlignment = NSTextAlignmentRight;
    [self addSubview:view];
    _dataLabel = view;
  }
  return _dataLabel;
}

- (void)setTitle:(NSString *)title {
  _title = title;
  self.titleLabel.text = title;
}

- (void)setValue:(NSString *)value {
  _value = value;
  self.dataLabel.text = value;
}

- (void)resetValue {
  [self setValue:@"-"];
}

@end

@interface GBSeatQualityView ()

@property (nonatomic, strong) GBNetQualityModel *netQuality;
@property (nonatomic, assign) BOOL isUpdatingQuality;

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) GBSeatQualityHorizontalView *kbpsView;
@property (nonatomic, strong) GBSeatQualityHorizontalView *rttView;
@property (nonatomic, strong) GBSeatQualityHorizontalView *plrView;

@end

@implementation GBSeatQualityView

- (instancetype)init {
  self = [super init];
  if (self) {
    self.backgroundColor = [UIColor colorWithHexString:@"#250D33FF"];
    self.alpha = 0.92;
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
  }
  return self;
}

- (void)updateConstraints {
  [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];
  [super updateConstraints];
}

- (UIStackView *)stackView {
  if (!_stackView) {
    UIStackView *view = [[UIStackView alloc] initWithArrangedSubviews:@[
      self.kbpsView,
      self.rttView,
      self.plrView,
    ]];
    
//    [view.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//      if (idx % 2 == 0) {
//        obj.backgroundColor = UIColorHex(3B0A76);
//      }else {
//        obj.backgroundColor = UIColorHex(420E81);
//      }
//    }];
    
    view.axis = UILayoutConstraintAxisVertical;
    view.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:view];
    _stackView = view;
  }
  return _stackView;
}

- (GBSeatQualityHorizontalView *)kbpsView {
  if (!_kbpsView) {
    _kbpsView = [[GBSeatQualityHorizontalView alloc] init];
    _kbpsView.title = @"码率";
  }
  return _kbpsView;
}

- (GBSeatQualityHorizontalView *)rttView {
  if (!_rttView) {
    _rttView = [[GBSeatQualityHorizontalView alloc] init];
    _rttView.title = @"延迟";
  }
  return _rttView;
}

- (GBSeatQualityHorizontalView *)plrView {
  if (!_plrView) {
    _plrView = [[GBSeatQualityHorizontalView alloc] init];
    _plrView.title = @"丢包率";
  }
  return _plrView;
}

- (void)setNetQuality:(GBNetQualityModel *)netQuality {
  _netQuality = netQuality;
  
  if (!self.isUpdatingQuality) {
    self.isUpdatingQuality = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self updateWithNetQuality];
      self.isUpdatingQuality = NO;
    });
  }
}

- (void)resetAllValues {
  NSArray *views = self.stackView.arrangedSubviews;
  for (UIView *view in views) {
    if ([view isKindOfClass:[GBSeatQualityHorizontalView class]]) {
      GBSeatQualityHorizontalView *v = (GBSeatQualityHorizontalView *)view;
      [v resetValue];
    }
  }
}

- (void)updateWithNetQuality {
  GBNetQualityModel *netQuality = self.netQuality;
  
  NSString *kbps = @"-";
  NSString *rtt = @"-";
  NSString *plr = @"-";
  
  if (netQuality.kbps >= 0) {
    kbps = [NSString stringWithFormat:@"%.0fkbps", netQuality.kbps];
  }
  if (netQuality.rtt >= 0) {
    rtt = [NSString stringWithFormat:@"%dms", netQuality.rtt];
  }
  if (netQuality.packetLossRate >= 0) {
    plr = [NSString stringWithFormat:@"%.0f%%", netQuality.packetLossRate * 100.0];
  }
  [self.kbpsView setValue:kbps];
  [self.rttView setValue:rtt];
  [self.plrView setValue:plr];
}

@end
