//
//  GBRoundResultRuleView.m
//  KTVGrab
//
//  Created by Vic on 2022/5/12.
//

#import "GBRoundResultRuleView.h"
#import <Masonry/Masonry.h>

@interface GBRoundResultRuleView ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation GBRoundResultRuleView

- (instancetype)init {
  self = [super init];
  if (self) {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.layer.cornerRadius = 12;
  }
  return self;
}

- (void)updateConstraints {
  [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self);
    make.top.equalTo(self).offset(24);
    make.bottom.equalTo(self).inset(27);
    make.height.mas_equalTo(47);
  }];
  [super updateConstraints];
}

- (UILabel *)label {
  if (!_label) {
    UILabel *view = [[UILabel alloc] init];
    view.text = @"系统播放演唱歌曲，抢到麦的用户\n进行演唱，挑战结束后会显示分数";
    view.numberOfLines = 0;
    view.font = [UIFont systemFontOfSize:14];
    view.textColor = UIColor.whiteColor;
    
    // 调整行间距至 20 行高
    CGFloat lineHeight = 20;
    CGFloat lineSpacing = (lineHeight - view.font.lineHeight) * 2;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = lineSpacing;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    view.attributedText = [[NSAttributedString alloc] initWithString:view.text attributes:attributes];
    
    
    [self addSubview:view];
    _label = view;
  }
  return _label;
}

@end
