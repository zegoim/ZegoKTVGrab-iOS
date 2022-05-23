//
//  ZGLSAlert.h
//  GoChat
//
//  Created by Vic on 2021/8/31.
//  Copyright © 2021 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface GBAlert : NSObject

+ (instancetype)alert;

// 两个按钮
- (void)configWithTitle:(NSString *)title
                content:(NSString *)content
        leftActionTitle:(NSString *)leftActionTitle
             leftAction:(void(^)(void))leftAction
       rightActionTitle:(NSString *)rightActionTitle
            rightAction:(void(^)(void))rightAction;

// 一个按钮
- (void)configWithTitle:(NSString *)title
                content:(NSString *)content
            actionTitle:(NSString *)actionTitle
                 action:(void(^)(void))action;

- (void)show;
- (void)close;

@end

//NS_ASSUME_NONNULL_END
