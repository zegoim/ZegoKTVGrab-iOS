//
//  GBPanelButton.h
//  KTVGrab
//
//  Created by Vic on 2022/3/9.
//

#import "GBVerticalLayoutButton.h"
#import "GBPanelEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBPanelButton : GBVerticalLayoutButton

@property (nonatomic, assign) GBPanelItemType itemType;

@property (nonatomic, assign) BOOL enableFlag;

@end

NS_ASSUME_NONNULL_END
