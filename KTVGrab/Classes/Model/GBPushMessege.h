//
//  GBPushMessege.h
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import <Foundation/Foundation.h>
#import "GBTypeDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * ZPush 消息体
 */
@interface GBPushMessege : NSObject

@property (nonatomic, assign) GBPushCommand cmd;
@property (nonatomic, assign) long long timestamp;
@property (nonatomic, copy) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
