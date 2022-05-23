//
//  GBRoundGradeView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import "GBRoundGradeView.h"
#import "GBRoundGrade.h"
#import "GBGradeItemView.h"
#import <Masonry/Masonry.h>

@interface GBRoundGradeView ()

@property (nonatomic, strong) UIStackView *stackView;

/// 抢唱数量 view
@property (nonatomic, strong) GBGradeItemView *grabCountItem;

/// 成功率 view
@property (nonatomic, strong) GBGradeItemView *passRateItem;

/// 总分 view
@property (nonatomic, strong) GBGradeItemView *totalScoreItem;

@end

@implementation GBRoundGradeView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
}

- (void)updateConstraints {
  [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self);
    make.left.right.equalTo(self);
  }];
  [super updateConstraints];
}

#pragma mark - View
- (UIStackView *)stackView {
  if (!_stackView) {
    _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
      self.grabCountItem,
      self.passRateItem,
      self.totalScoreItem
    ]];
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:_stackView];
  }
  return _stackView;
}

- (GBGradeItemView *)grabCountItem {
  if (!_grabCountItem) {
    _grabCountItem = [[GBGradeItemView alloc] init];
    _grabCountItem.titleString = @"抢唱";
  }
  return _grabCountItem;
}

- (GBGradeItemView *)passRateItem {
  if (!_passRateItem) {
    _passRateItem = [[GBGradeItemView alloc] init];
    _passRateItem.titleString = @"成功率";
  }
  return _passRateItem;
}

- (GBGradeItemView *)totalScoreItem {
  if (!_totalScoreItem) {
    _totalScoreItem = [[GBGradeItemView alloc] init];
    _totalScoreItem.titleString = @"总分";
  }
  return _totalScoreItem;
}

- (void)setGrade:(GBRoundGrade *)grade {
  _grade = grade;
  self.grabCountItem.dataString = [NSString stringWithFormat:@"%lu首", grade.grabCount];
  self.totalScoreItem.dataString = [NSString stringWithFormat:@"%lu分", grade.score];
  
  CGFloat passRate = grade.passCount * 100.0 / grade.grabCount;
  if (grade.grabCount <= 0) {
    passRate = 0;
  }
  self.passRateItem.dataString = [NSString stringWithFormat:@"%.0f%%", passRate];
}

@end
