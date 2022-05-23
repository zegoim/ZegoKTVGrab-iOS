//
//  GBRoomPanelView.h
//  KTVGrab
//
//  Created by Vic on 2022/3/9.
//

#import <UIKit/UIKit.h>
#import "GBPanelEnums.h"

NS_ASSUME_NONNULL_BEGIN

/// Has intrinsic size
@interface GBRoomPanelView : UIView

@property (nonatomic, strong) void(^alertMicIsDisabled)(void);
@property (nonatomic, strong) void(^shouldModalAudioConfigPanel)(void);
@property (nonatomic, strong) void(^shouldOpenMicrophone)(BOOL on);

- (void)setMicEnable:(BOOL)visible;
- (void)setAudioConfigVisible:(BOOL)visible;

@end

NS_ASSUME_NONNULL_END
