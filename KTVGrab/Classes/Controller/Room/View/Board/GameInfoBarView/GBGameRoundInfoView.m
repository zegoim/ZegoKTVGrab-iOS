//
//  GBGameRoundInfoView.m
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import "GBGameRoundInfoView.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>

@interface GBGameRoundInfoView ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation GBGameRoundInfoView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.backgroundColor = [UIColor colorWithHexString:@"1A063EFF"];
  self.alpha = 0.5;
}


- (void)layoutSubviews {
  self.layer.cornerRadius = 0.5 * CGRectGetHeight(self.bounds);
  
  [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self);
  }];
}

- (void)setIndex:(NSInteger)index {
  [self setIndex:index totalCount:self.totalCount];
}

- (void)setTotalCount:(NSInteger)totalCount {
  [self setIndex:self.index totalCount:totalCount];
}

- (void)setIndex:(NSInteger)index totalCount:(NSInteger)totalCount {
  _index = index;
  _totalCount = totalCount;
  self.label.text = [NSString stringWithFormat:@"%ld/%ld", index, totalCount];
}

- (UILabel *)label {
  if (!_label) {
    _label = [[UILabel alloc] init];
    _label.textColor = UIColor.whiteColor;
    _label.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    [self addSubview:_label];
  }
  return _label;
}

@end
