//
//  GBRoomVC.h
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import <UIKit/UIKit.h>

@class GBRunningRoomService;

NS_ASSUME_NONNULL_BEGIN

@interface GBRoomVC : UIViewController

- (instancetype)initWithService:(GBRunningRoomService *)runningRoomService;

@end

NS_ASSUME_NONNULL_END
