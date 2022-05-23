//
//  GBTitleTextField.m
//  KTVGrab
//
//  Created by Vic on 2022/5/12.
//

#import "GBTitleTextField.h"
#import "GBRoundRectTextField.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

@interface GBTitleTextField ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) GBRoundRectTextField *textField;

@end

@implementation GBTitleTextField
@synthesize text = _text;

- (BOOL)canBecomeFirstResponder {
  return [self.textField canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder {
  return [self.textField becomeFirstResponder];
}

- (void)updateConstraints {
  [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.left.equalTo(self);
    make.height.mas_equalTo(20);
  }];
  
  [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
    make.height.mas_equalTo(44);
    make.left.right.bottom.equalTo(self);
  }];
  
  [super updateConstraints];
}

- (void)setTitle:(NSString *)title {
  self.titleLabel.text = title;
}

- (void)setTextFieldPlaceholder:(NSString *)placeholder {
  NSAttributedString *placeholderString = [[NSAttributedString alloc] initWithString:placeholder attributes:@{
    NSForegroundColorAttributeName: UIColorHex(523E70),
  }];
  self.textField.attributedPlaceholder = placeholderString;
}

- (void)setTextFieldReturnKeyType:(UIReturnKeyType)type {
  [self.textField setReturnKeyType:type];
}

- (void)setText:(NSString *)text {
  self.textField.text = text;
}

- (NSString *)text {
  return self.textField.text;
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    UILabel *view = [[UILabel alloc] init];
    view.font = [UIFont systemFontOfSize:14];
    view.textColor = UIColor.whiteColor;
    [self addSubview:view];
    _titleLabel = view;
  }
  return _titleLabel;
}

- (GBRoundRectTextField *)textField {
  if (!_textField) {
    GBRoundRectTextField *view = [[GBRoundRectTextField alloc] init];
    [view addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    view.delegate = self;
    view.backgroundColor = [UIColor colorWithHexString:@"#371963FF"];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.alpha = 0.8;
    view.textColor = UIColor.whiteColor;
    [self addSubview:view];
    _textField = view;
  }
  return _textField;
}

- (void)textFieldEditingChanged:(UITextField *)textField {
  if (self.onTextFieldShouldReturnBlock) {
    self.onTextFieldEditingBlock(textField.text);
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (self.onTextFieldShouldReturnBlock) {
    self.onTextFieldShouldReturnBlock();
  }
  return YES;
}

@end
