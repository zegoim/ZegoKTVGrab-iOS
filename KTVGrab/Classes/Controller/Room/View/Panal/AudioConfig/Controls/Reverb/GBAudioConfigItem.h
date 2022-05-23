//
//  ZegoAudioConfigItem.h
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/21.
//

#import <UIKit/UIKit.h>

@class GBAudioConfigItemVM;

NS_ASSUME_NONNULL_BEGIN

@interface GBAudioConfigItem : UICollectionViewCell

@property (nonatomic, strong) GBAudioConfigItemVM *viewModel;

@end

NS_ASSUME_NONNULL_END
