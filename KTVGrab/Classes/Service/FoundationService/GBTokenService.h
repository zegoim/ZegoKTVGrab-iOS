//
//  GBTokenService.h
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBTokenService : NSObject

+ (instancetype)shared;

/**
 * 获取 token, 异步
 * @param completion 获取 token 完成回调
 * @param forceUpdate 是否强制更新 token, 若否, 则优先返回缓存 token
 */
- (void)getTokenWithCompletion:(void (^)(NSString * _Nullable token))completion shouldForceUpdate:(BOOL)forceUpdate;

/**
 * 获取缓存 token, 同步
 */
- (NSString *)getCacheToken;

/**
 * 更新缓存 token
 */
- (void)updateToken:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
