//
//  GBFoundationModel.h
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 抢唱模块依赖的外部数据
 */
@interface GBExternalDependency : NSObject

/**
 * AppID
 */
@property (nonatomic, assign) unsigned int appID;

/**
 * AppSign
 */
@property (nonatomic, copy) NSString *appSign;

/**
 * 用户 userID
 */
@property (nonatomic, copy) NSString *userID;

/**
 * 用户 UserName
 */
@property (nonatomic, copy, nullable) NSString *userName;

/**
 * 用户头像
 */
@property (nonatomic, copy) NSString *avatar;

/**
 * 业务后台地址
 */
@property (nonatomic, copy) NSString *hostUrlString;

/**
 * 是否为测试环境, 若为测试环境, 则会在 host 后的路径前添加 /alpha
 * 默认为 NO
 */
@property (nonatomic, assign) BOOL isTestEnv;

/**
 * 单例
 */
+ (instancetype)shared;

/**
 * 校验属性数据是否完整
 * 若完整则通过, 若不完整则抛异常中止
 */
- (void)validate;

@end

NS_ASSUME_NONNULL_END
