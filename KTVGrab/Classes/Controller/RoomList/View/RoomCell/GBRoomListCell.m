//
//  GBRoomListCell.m
//  KTVGrab
//
//  Created by Vic on 2022/3/13.
//

#import "GBRoomListCell.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "GBImage.h"

@interface GBRoomListCell ()

/// 背景图片
@property (nonatomic, strong) UIImageView *bgImageView;

/// 用于添加渐变图层
@property (nonatomic, strong) UIView *gradientLayerView;

/// 用于展示房间名称
@property (nonatomic, strong) UILabel *roomNameLabel;

/// 用于展示小的用户 icon
@property (nonatomic, strong) UIImageView *iconImageView;

/// 用于展示 上麦人数 / 麦位数
@property (nonatomic, strong) UILabel *userCountLabel;

/// 上方渐变层
@property (nonatomic, strong) CAGradientLayer *topGradientLayer;

/// 下方渐变层
@property (nonatomic, strong) CAGradientLayer *botGradientLayer;

@end

@implementation GBRoomListCell

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
  [self.contentView addSubview:self.bgImageView];
  [self.contentView addSubview:self.gradientLayerView];
  [self.gradientLayerView.layer addSublayer:self.topGradientLayer];
  [self.gradientLayerView.layer addSublayer:self.botGradientLayer];
  [self.contentView addSubview:self.roomNameLabel];
  [self.contentView addSubview:self.iconImageView];
  [self.contentView addSubview:self.userCountLabel];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.layer.cornerRadius = 14;
  self.layer.masksToBounds = YES;
  
  UIView *contentView = self.contentView;
  
  CGFloat w = CGRectGetWidth(self.bounds);
  
  self.topGradientLayer.frame = CGRectMake(0, 0, w, 44);
  self.botGradientLayer.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 70, w, 70);
  
  [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(contentView);
  }];
  
  [self.gradientLayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(contentView);
  }];
  
  [self.roomNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(contentView).offset(14);
    make.bottom.equalTo(contentView).offset(-14);
    make.right.lessThanOrEqualTo(contentView).offset(-14);
  }];
  
  [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(contentView).offset(14);
    make.left.equalTo(contentView).offset(12);
    make.width.height.mas_equalTo(12);
  }];
  
  [self.userCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.iconImageView);
    make.left.equalTo(self.iconImageView.mas_right).offset(5);
  }];
  
}

#pragma mark - View
- (UIImageView *)bgImageView {
  if (!_bgImageView) {
    _bgImageView = [[UIImageView alloc] init];
  }
  return _bgImageView;
}

- (UIView *)gradientLayerView {
  if (!_gradientLayerView) {
    _gradientLayerView = [[UIView alloc] init];
  }
  return _gradientLayerView;
}

- (UILabel *)roomNameLabel {
  if (!_roomNameLabel) {
    _roomNameLabel = [[UILabel alloc] init];
    _roomNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _roomNameLabel.textColor = UIColor.whiteColor;
    _roomNameLabel.numberOfLines = 0;
  }
  return _roomNameLabel;
}

- (UIImageView *)iconImageView {
  if (!_iconImageView) {
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView.image = [GBImage imageNamed:@"gb_icon_user"];
  }
  return _iconImageView;
}

- (UILabel *)userCountLabel {
  if (!_userCountLabel) {
    _userCountLabel = [[UILabel alloc] init];
    _userCountLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _userCountLabel.textColor = UIColor.whiteColor;
  }
  return _userCountLabel;
}

- (CAGradientLayer *)topGradientLayer {
  if (!_topGradientLayer) {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];

    UIColor *beginColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:0];
    UIColor *midColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:0.3];
    UIColor *endColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:0.6];
    
    gradientLayer.colors = @[
      (__bridge id)beginColor.CGColor,
      (__bridge id)midColor.CGColor,
      (__bridge id)endColor.CGColor
    ];
    gradientLayer.locations = @[@0.0, @0.5, @1.0];
    gradientLayer.startPoint = CGPointMake(0.5, 1);
    gradientLayer.endPoint = CGPointMake(0.5, 0);
    _topGradientLayer = gradientLayer;
  }
  return _topGradientLayer;
}

- (CAGradientLayer *)botGradientLayer {
  if (!_botGradientLayer) {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    UIColor *beginColor = [UIColor clearColor];
    UIColor *midColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:0.3];
    UIColor *endColor = [UIColor colorWithRed:66/255.0 green:0 blue:66/255.0 alpha:0.6];
    
    gradientLayer.colors = @[
      (__bridge id)beginColor.CGColor,
      (__bridge id)midColor.CGColor,
      (__bridge id)endColor.CGColor
    ];
    gradientLayer.locations = @[@0.0, @0.4, @1.0];
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);
    _botGradientLayer = gradientLayer;
  }
  return _botGradientLayer;
}

#pragma mark - Public
- (void)setViewModel:(GBRoomListCellVM *)viewModel {
  _viewModel = viewModel;
  GBRoomInfo *roomInfo = viewModel.roomInfo;
  [self.bgImageView setImageWithURL:[NSURL URLWithString:roomInfo.imgURLString] placeholder:[GBImage imageNamed:@"gb_room_bg_placeholder"]];
  self.roomNameLabel.text = roomInfo.roomName;
  self.userCountLabel.text = [NSString stringWithFormat:@"%lu/%lu", roomInfo.userOnstageCount, roomInfo.seatsCount];
}


@end
