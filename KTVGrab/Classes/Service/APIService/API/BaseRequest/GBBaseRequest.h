//
//  GBBaseRequest.h
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import <ZegoNetwork/ZegoNetwork.h>

typedef void(^GBNetworkCompletionBlock)(BOOL suc, NSError * _Nullable err, id _Nullable reserved);

NS_ASSUME_NONNULL_BEGIN


@interface GBBaseRequest : ZegoNetworkBaseRequest

@property (nonatomic, copy, readonly) NSString *uid;

@property (nonatomic, copy, readonly) NSString *userName;

/// 接口路径
- (NSString *)path;

/// 便利方法, 用于网络请求封装
/// @param completionBlock 外界的完成回调 block
/// @param block 成功后的执行内容
- (void)gb_startWithCompletionBlock:(GBNetworkCompletionBlock)completionBlock dataHandleBlock:(void (^)(NSDictionary * _Nullable data))block;

@end

NS_ASSUME_NONNULL_END
