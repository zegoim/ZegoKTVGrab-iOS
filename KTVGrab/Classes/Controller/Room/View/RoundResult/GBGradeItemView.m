//
//  GBGradeItemView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import "GBGradeItemView.h"
#import <Masonry/Masonry.h>

@interface GBGradeItemView ()

@property (nonatomic, strong) UILabel *dataLabel;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GBGradeItemView

- (void)updateConstraints {
  
  [self.dataLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self);
    make.centerX.equalTo(self);
  }];
  
  [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.dataLabel.mas_bottom).offset(8);
    make.bottom.equalTo(self);
    make.centerX.equalTo(self);
  }];
  
  [super updateConstraints];
}

- (UILabel *)dataLabel {
  if (!_dataLabel) {
    _dataLabel = [[UILabel alloc] init];
    _dataLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
    _dataLabel.textColor = [UIColor whiteColor];
    _dataLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_dataLabel];
  }
  return _dataLabel;
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.alpha = 0.7;
    _titleLabel.font = [UIFont systemFontOfSize:12];
    _titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
  }
  return _titleLabel;
}

- (void)setTitleString:(NSString *)titleString {
  _titleString = titleString;
  self.titleLabel.text = titleString;
}

- (void)setDataString:(NSString *)dataString {
  _dataString = dataString;
  self.dataLabel.text = dataString;
}

@end
