//
//  ZegoAudioConfigItem.m
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/21.
//

#import "GBAudioConfigItem.h"
#import "GBAudioTitleLabel.h"
#import "GBAudioConfigImageView.h"
#import "GBAudioConfigItemVM.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "GBImage.h"

@interface GBAudioConfigItem ()

@property (nonatomic, strong) GBAudioConfigImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) CALayer *overlay;
@property (nonatomic, assign) BOOL itemSelected;

@end

@implementation GBAudioConfigItem

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
  [self.contentView addSubview:self.imageView];
  [self.contentView addSubview:self.label];
}

- (void)updateConstraints {
  [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.contentView);
    make.top.equalTo(self.contentView).offset(2);
  }];
  
  [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.contentView);
    make.bottom.equalTo(self.contentView);
  }];
  [super updateConstraints];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.imageView.layer.cornerRadius = 25;
  self.imageView.layer.masksToBounds = YES;
}

- (void)setViewModel:(GBAudioConfigItemVM *)viewModel {
  _viewModel = viewModel;
  [self.imageView setImageName:viewModel.imageName];
  self.label.text = viewModel.text;
  self.itemSelected = viewModel.itemSelected;
}

- (void)setItemSelected:(BOOL)itemSelected {
  _itemSelected = itemSelected;
  [self.imageView setSelected:itemSelected];
  if (itemSelected) {
    self.label.textColor = [UIColor colorWithHexString:@"#FF1055FF"];
  }else {
    self.label.textColor = UIColor.whiteColor;
  }
}

- (GBAudioConfigImageView *)imageView {
  if (!_imageView) {
    _imageView = [[GBAudioConfigImageView alloc] init];
  }
  return _imageView;
}

- (UILabel *)label {
  if (!_label) {
    _label = [[GBAudioTitleLabel alloc] init];
    _label.font = [UIFont systemFontOfSize:11];
  }
  return _label;
}

@end
