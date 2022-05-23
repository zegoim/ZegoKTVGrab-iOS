//
//  ZegoAudioConfigVC.h
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/18.
//

#import "GoHalfModalPresentingVC.h"

@class GBRoomInfo;

NS_ASSUME_NONNULL_BEGIN

@interface ZegoAudioConfigVC : GoHalfModalPresentingVC

@property (nonatomic, strong) GBRoomInfo *roomInfo;

@end

NS_ASSUME_NONNULL_END
