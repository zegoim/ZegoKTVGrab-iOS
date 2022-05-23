//
//  GBRoomListCell.h
//  KTVGrab
//
//  Created by Vic on 2022/3/13.
//

#import <UIKit/UIKit.h>
#import "GBRoomListCellVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBRoomListCell : UICollectionViewCell

@property (nonatomic, strong) GBRoomListCellVM *viewModel;

@end

NS_ASSUME_NONNULL_END
