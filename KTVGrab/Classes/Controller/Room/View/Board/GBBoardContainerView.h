//
//  GBBoardContainerView.h
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import <UIKit/UIKit.h>
#import "GBEnums.h"

@class GBSong;
@class GBUser;
@class GBRoomInfo;

/// No intrinsic size
NS_ASSUME_NONNULL_BEGIN

@interface GBBoardContainerView : UIView

@property (nonatomic, strong) void(^onClickStartGameButton)(void);

- (void)setRoomInfo:(GBRoomInfo *)roomInfo checkSong:(BOOL)checkSong;

- (void)setSong:(GBSong *)clip;

/// grabbed info view
- (void)setGrabUser:(GBUser *)user;

- (void)setProgress:(NSInteger)progress pitch:(int)pitch;

@end

NS_ASSUME_NONNULL_END
