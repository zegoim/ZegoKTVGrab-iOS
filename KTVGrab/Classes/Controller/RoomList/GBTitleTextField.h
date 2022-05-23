//
//  GBTitleTextField.h
//  KTVGrab
//
//  Created by Vic on 2022/5/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBTitleTextField : UIView

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) void(^onTextFieldShouldReturnBlock)(void);
@property (nonatomic, strong) void(^onTextFieldEditingBlock)(NSString *text);

- (void)setTitle:(NSString *)title;
- (void)setTextFieldPlaceholder:(NSString *)placeholder;
- (void)setTextFieldReturnKeyType:(UIReturnKeyType)type;

@end

NS_ASSUME_NONNULL_END
