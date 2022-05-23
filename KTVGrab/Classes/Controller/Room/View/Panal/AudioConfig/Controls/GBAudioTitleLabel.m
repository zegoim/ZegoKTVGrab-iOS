//
//  ZegoAudioTitleLabel.m
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/21.
//

#import "GBAudioTitleLabel.h"

@implementation GBAudioTitleLabel

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.textColor = UIColor.whiteColor;
  self.font = [UIFont systemFontOfSize:14];
}

@end
