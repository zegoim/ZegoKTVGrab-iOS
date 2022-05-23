//
//  GBAudioQualityService.h
//  KTVGrab
//
//  Created by Vic on 2022/4/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBAudioQualityService : NSObject

/**
 * 标准音频配置
 */
- (void)setStandardAudioQuality;

/**
 * 高质量音频配置
 */
- (void)setHighAudioQuality;

@end

NS_ASSUME_NONNULL_END
