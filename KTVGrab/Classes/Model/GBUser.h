//
//  GBUser.h
//  KTVGrab
//
//  Created by Vic on 2022/3/4.
//

#import <Foundation/Foundation.h>
#import "GBEnums.h"
#import "GBUserRole.h"

@class GBUserRespModel;
@class GBRoundGrade;

NS_ASSUME_NONNULL_BEGIN

@interface GBUser : NSObject

/**
 * 用户 ID
 */
@property (nonatomic, copy) NSString *userID;

/**
 * 用户名
 */
@property (nonatomic, copy) NSString *userName;

/**
 * 用户头像 URL 地址
 */
@property (nonatomic, copy) NSString *avatarURLString;

/**
 * 用户角色
 * 1-听众
 * 2-游戏参与者
 * 3-房主
 */
@property (nonatomic, assign, readonly) GBUserRoleType roleType;

/**
 * 用户角色信息, 包含权限信息
 */
@property (nonatomic, strong) GBUserRole *role;

/**
 * 用户登录时间
 */
@property (nonatomic, assign) NSUInteger loginTime;

/**
 * 用户麦克风状态
 * 0-未设置
 * 1-关闭
 * 2-开启
 */
@property (nonatomic, assign, getter=isMicOn) BOOL micOn;

/**
 * 用户是否在台上
 * 1-不在台上
 * 2-在台上
 */
@property (nonatomic, assign) BOOL onstage;

/**
 * 麦位序号
 */
@property (nonatomic, assign) NSUInteger micIndex;

/**
 * 该轮分数
 */
@property (nonatomic, strong) GBRoundGrade *grade;

/**
 * 根据网络对象更新 self 的数据
 */
- (void)updateWithUserRespModel:(GBUserRespModel *)model;

@end

NS_ASSUME_NONNULL_END
