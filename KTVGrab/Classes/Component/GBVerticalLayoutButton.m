//
//  GBVerticalLayoutButton.m
//  KTVGrab
//
//  Created by Vic on 2022/3/9.
//

#import "GBVerticalLayoutButton.h"

@implementation GBVerticalLayoutButton

- (void)layoutSubviews {
  [super layoutSubviews];
  [self adjustImageAndTitleOffsetsForButton];
}

- (void)adjustImageAndTitleOffsetsForButton {
  CGFloat spacing = self.verticalSpacing ? self.verticalSpacing : 3;
  CGSize imageSize = self.imageView.frame.size;
  CGSize titleSize = self.titleLabel.frame.size;
  
  // top, left, bottom, right
  [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageSize.width, -(imageSize.height + spacing), 0)];
  [self setImageEdgeInsets:UIEdgeInsetsMake(-(titleSize.height + spacing), 0, 0, -titleSize.width)];
}

@end
