//
//  ZGKTVGuestCell.h
//  GoChat
//
//  Created by Vic on 2021/10/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBSeatCellVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBSeatCell : UICollectionViewCell

@property (nonatomic, strong) GBSeatCellVM *cellVM;

@end

NS_ASSUME_NONNULL_END
