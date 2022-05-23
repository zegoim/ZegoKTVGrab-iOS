//
//  ZegoAudioReverbSelectView.h
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/21.
//

#import <UIKit/UIKit.h>

@class GBAudioConfigItemVM;

NS_ASSUME_NONNULL_BEGIN

@protocol GBAudioReverbListener <NSObject>

- (void)onReverbSelectedAtIndex:(NSUInteger)index manual:(BOOL)manual;

@end

/// 所有调音部分, 主要是 UICollectionView
@interface GBAudioReverbSelectView : UIView

@property (nonatomic, copy) NSString *title;

- (void)setListener:(id<GBAudioReverbListener>)listener;
- (void)setDefaultReverb;
- (void)selectReverbAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
