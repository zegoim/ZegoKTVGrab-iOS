//
//  GBPanelButton.m
//  KTVGrab
//
//  Created by Vic on 2022/3/9.
//

#import "GBPanelButton.h"
#import <Masonry/Masonry.h>

@implementation GBPanelButton

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
    self.enableFlag = YES;
  }
  return self;
}

- (void)updateConstraints {
  [self mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(40, 48));
  }];
  [super updateConstraints];
}

- (void)setupUI {
  [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
  self.titleLabel.font = [UIFont systemFontOfSize:9];
}

- (void)setEnableFlag:(BOOL)enableFlag {
  _enableFlag = enableFlag;
  self.alpha = enableFlag ? 1 : 0.5;
}

@end
