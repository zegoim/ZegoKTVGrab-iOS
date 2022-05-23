//
//  GBSEIService.h
//  KTVGrab
//
//  Created by Vic on 2022/3/31.
//

#import <Foundation/Foundation.h>

@class GBSEIModel;

NS_ASSUME_NONNULL_BEGIN

@interface GBSEIService : NSObject

/**
 * 发送 SEI 信息
 */
- (void)sendSEIWithRole:(NSUInteger)role
                 songID:(NSString *)songID
              playerState:(NSUInteger)playerState
               progress:(NSUInteger)progress
               duration:(NSUInteger)duration;

- (GBSEIModel *)seiModelWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
