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
 * 停止重复请求token
 */
- (void)stop;

/**
 * 开始请求 token, 并且开启 token 循环请求
 */
- (void)requestToken:(void(^)(NSString *token))complete;

/**
 * 获取缓存 token, 同步
 */
- (NSString *)getCacheToken;

@end

NS_ASSUME_NONNULL_END
