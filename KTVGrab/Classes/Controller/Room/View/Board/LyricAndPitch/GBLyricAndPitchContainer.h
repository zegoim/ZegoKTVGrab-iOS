//
//  GBLyricAndPitchContainer.h
//  AFNetworking
//
//  Created by Vic on 2022/3/22.
//

#import <UIKit/UIKit.h>

@class GBSong;

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic size
@interface GBLyricAndPitchContainer : UIView

@property (nonatomic, assign) BOOL pitchViewVisible;

- (void)setSong:(GBSong *)song;
- (void)setProgress:(NSInteger)progress pitch:(int)pitch;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
