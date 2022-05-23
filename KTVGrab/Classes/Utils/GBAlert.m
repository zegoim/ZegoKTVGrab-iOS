//
//  ZGLSAlert.m
//  GoChat
//
//  Created by Vic on 2021/8/31.
//  Copyright © 2021 zego. All rights reserved.
//

#import "GBAlert.h"
#import <LEEAlert/LEEAlert.h>

@interface GBAlert ()

@property (nonatomic, strong) LEEAlertConfig *leeAlert;

@end

@implementation GBAlert

+ (instancetype)alert {
  GBAlert *alert = [[GBAlert alloc] init];
  return alert;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    LEEAlertConfig *leeAlert = LEEAlert.alert;
    _leeAlert = leeAlert;
  }
  return self;
}

- (void)configWithTitle:(NSString *)title
                content:(NSString *)content
        leftActionTitle:(NSString *)leftActionTitle
             leftAction:(void(^)(void))leftAction
       rightActionTitle:(NSString *)rightActionTitle
            rightAction:(void(^)(void))rightAction {
  
  LEEBaseConfigModel *alert = self.leeAlert.config;
  
  alert
  .LeeCornerRadius(16)
//  .LeeHeaderColor([UIColor colorWithRed:17/255.0 green:16/255.0 blue:20/255.0 alpha:0.84]);
  .LeeHeaderColor([UIColor colorWithRed:17/255.0 green:16/255.0 blue:20/255.0 alpha:1])
  .LeeBackgroundStyleTranslucent(0);
  
  if (title.length > 0) {
    alert.LeeAddTitle(^(UILabel * _Nonnull label) {
      label.text = title;
      label.textColor = [UIColor whiteColor];
      label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    });
  }
  
  if (content.length > 0) {
    alert.LeeAddContent(^(UILabel * _Nonnull label) {
      NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
      paragraphStyle.minimumLineHeight = 21;
      NSMutableAttributedString * str = [[NSMutableAttributedString alloc]init];
      NSAttributedString * attrContent = [[NSAttributedString alloc]initWithString:content attributes:@{
        NSFontAttributeName:[UIFont systemFontOfSize:14 weight:UIFontWeightRegular],
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSParagraphStyleAttributeName:paragraphStyle,
      }];
      [str appendAttributedString:attrContent];
      
      label.attributedText = str;
      label.textAlignment = NSTextAlignmentCenter;
    });
  }
  
  if (leftActionTitle) {
    alert.LeeAddAction(^(LEEAction * _Nonnull action) {
      action.title = leftActionTitle ?: @"";
      action.titleColor = [UIColor whiteColor];
      action.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
      action.height = 50;
      action.backgroundColor = [UIColor colorWithRed:17/255.0 green:16/255.0 blue:20/255.0 alpha:0.84];
      action.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
      if (rightAction) {
        action.borderPosition = LEEActionBorderPositionRight | LEEActionBorderPositionTop;
      }else {
        action.borderPosition = LEEActionBorderPositionTop;
      }
      action.borderWidth = 0.5;
      action.clickBlock = ^{
        if (leftAction) {
          leftAction();
        }
      };
    });
  }
  if (rightActionTitle) {
    alert.LeeAddAction(^(LEEAction * _Nonnull action) {
      action.title = rightActionTitle ?: @"";
      action.titleColor = [UIColor whiteColor];
      action.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
      action.height = 50;
      action.backgroundColor = [UIColor colorWithRed:17/255.0 green:16/255.0 blue:20/255.0 alpha:0.84];
      action.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
      action.borderPosition = LEEActionBorderPositionLeft | LEEActionBorderPositionTop;
      action.borderWidth = 0.5;
      action.clickBlock = ^{
        if (rightAction) {
          rightAction();
        }
      };
    });
  }
}

- (void)configWithTitle:(NSString *)title
                content:(NSString *)content
            actionTitle:(NSString *)actionTitle
                 action:(void(^)(void))action {
  [self configWithTitle:title content:content leftActionTitle:actionTitle leftAction:action rightActionTitle:nil rightAction:nil];
}

- (void)show {
  self.leeAlert.config.LeeShow();
}

- (void)close {
  [LEEAlert closeWithCompletionBlock:nil];
}

@end
