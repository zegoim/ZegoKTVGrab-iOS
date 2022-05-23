//
//  GBRoomListVC.h
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import <UIKit/UIKit.h>
#import "GBRoomListVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBRoomListVC : UIViewController

- (instancetype)initWithViewModel:(GBRoomListVM *)viewModel;

@end

NS_ASSUME_NONNULL_END
