//
//  GBRoundRectTextField.m
//  KTVGrab
//
//  Created by Vic on 2022/4/27.
//

#import "GBRoundRectTextField.h"

@implementation GBRoundRectTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 10, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 10, 0);
}

@end
