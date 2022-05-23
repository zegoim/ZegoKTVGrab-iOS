//
//  GBCreateRoomVC.h
//  KTVGrab
//
//  Created by Vic on 2022/3/7.
//

#import "GoHalfModalPresentingVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBCreateRoomVC : GoHalfModalPresentingVC

@property (nonatomic, strong) void(^onClickJoinRoomButton)(NSString *roomName, NSString *userName);

@end

NS_ASSUME_NONNULL_END
