//
//  GBBaseAuthRequest.h
//  KTVGrab
//
//  Created by Vic on 2022/3/12.
//

#import "GBBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBBaseAuthRequest : GBBaseRequest

/// Data 中的参数
- (NSDictionary * _Nullable)payload;

@end

NS_ASSUME_NONNULL_END
