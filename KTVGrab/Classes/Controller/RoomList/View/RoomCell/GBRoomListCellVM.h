//
//  GBRoomListCellVM.h
//  KTVGrab
//
//  Created by Vic on 2022/3/13.
//

#import <Foundation/Foundation.h>
#import "GBRoomInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBRoomListCellVM : NSObject

/// 房间数据模型
@property (nonatomic, strong) GBRoomInfo *roomInfo;

@end

NS_ASSUME_NONNULL_END
