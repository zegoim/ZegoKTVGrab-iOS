//
//  GBGameInfoBarView.h
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import <UIKit/UIKit.h>

@class GBSong;

NS_ASSUME_NONNULL_BEGIN

/// Has intrinsic height, no intrinsic width
@interface GBGameInfoBarView : UIView

- (void)setIndex:(NSInteger)index;

- (void)setTotalCount:(NSInteger)totalCount;

- (void)setProgress:(NSInteger)progress;

- (void)setProgressVisible:(BOOL)hidden;

- (void)setSong:(GBSong *)song;

@end

NS_ASSUME_NONNULL_END
