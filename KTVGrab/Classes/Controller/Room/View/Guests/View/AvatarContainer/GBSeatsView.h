//
//  ZGKTVRoomGuestView.h
//  GoChat
//
//  Created by Vic on 2021/10/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GBSeatInfo;

NS_ASSUME_NONNULL_BEGIN

@interface GBSeatsView : UIView

@property (nonatomic, assign) NSUInteger seatsCount;
@property (nonatomic, assign) NSUInteger columns;

@property (nonatomic, strong) void(^onSelectItemAtIndex)(NSUInteger index);

- (void)updateSeatList:(NSArray<GBSeatInfo *> *)seatList;
- (void)updateSeatMisc:(GBSeatInfo *)seat;

@end

NS_ASSUME_NONNULL_END
