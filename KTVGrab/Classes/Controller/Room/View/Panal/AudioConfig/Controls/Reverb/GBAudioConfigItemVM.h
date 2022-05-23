//
//  ZegoAudioConfigItemVM.h
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBAudioConfigItemVM : NSObject

/// 标题文本
@property (nonatomic,  copy ) NSString *text;

/// 混响图片 name
@property (nonatomic,  copy ) NSString *imageName;

/// 是否被选中
@property (nonatomic, assign) BOOL itemSelected;

/// RTC 对应的混响 preset 预设值
@property (nonatomic, assign) int preset;

@end

NS_ASSUME_NONNULL_END
