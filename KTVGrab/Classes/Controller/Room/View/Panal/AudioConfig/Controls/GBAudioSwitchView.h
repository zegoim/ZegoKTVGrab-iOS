//
//  ZegoAudioSwitchView.h
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBAudioSwitchView : UIView

@property (nonatomic, strong) void(^audioSwitchUpdateBlock)(BOOL enable);

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *descText;
@property (nonatomic, assign) BOOL enable;

@end

NS_ASSUME_NONNULL_END
