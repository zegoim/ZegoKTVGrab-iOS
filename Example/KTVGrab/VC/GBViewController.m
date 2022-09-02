//
//  GBViewController.m
//  KTVGrab
//
//  Created by Zego on 02/22/2022.
//  Copyright (c) 2022 Zego. All rights reserved.
//

#import "GBViewController.h"
#import <Masonry/Masonry.h>
#import "GBRoomListVC.h"
#import "GBExternalDependency.h"
#import "GBGrabMicView.h"
#import "KeyCenter.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import <ZIM/ZIM.h>

@interface GBViewController ()

@end

@implementation GBViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self loadGrabData];
  [self setupUI];
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachePath = paths.lastObject;
  NSLog(@"IM LOG DIR: %@", cachePath);
}

- (void)setupUI {
  self.title = @"抢唱Demo";
  self.view.backgroundColor = UIColor.grayColor;
  [self setupSubviews];
}

- (void)setupSubviews {
  UIButton *enterGrabBtn = [[UIButton alloc] init];
  [enterGrabBtn setTitle:@"进入抢唱" forState:UIControlStateNormal];
  [enterGrabBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
  [enterGrabBtn addTarget:self action:@selector(enterGrab) forControlEvents:UIControlEventTouchUpInside];
  
  NSString *env = ({
    NSString *str = @"Env:";
    NSString *suffix;
    if ([GBExternalDependency shared].isTestEnv) {
      suffix = @"Alpha";
    }else {
      suffix = @"Product";
    }
    str = [str stringByAppendingString:suffix];
    str;
  });
  
  UILabel *sdkVersionLabel = [[UILabel alloc] init];
  sdkVersionLabel.numberOfLines = 0;
  sdkVersionLabel.text = [NSString stringWithFormat:@"Express: %@\nZIM: %@\n%@", [ZegoExpressEngine getVersion], [ZIM getVersion], env];
  
  [self.view addSubview:enterGrabBtn];
  [self.view addSubview:sdkVersionLabel];
  
  [enterGrabBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
  }];
  
  [sdkVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.view);
    make.bottom.equalTo(self.view).offset(-50);
  }];
}

- (void)enterGrab {
  GBRoomListVC *vc = [[GBRoomListVC alloc] initWithViewModel:[GBRoomListVM new]];
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadGrabData {
  
  uint32_t randomDigit = arc4random_uniform(1000000000);
  NSString *randomUserID = [NSString stringWithFormat:@"%d", randomDigit];
  uint32_t rdmNameSuffix = arc4random_uniform(100);
  
  BOOL randomUser = YES;
  
  NSString *userID = randomUserID;
  NSString *userName = [NSString stringWithFormat:@"ios_grab_%d", rdmNameSuffix];
  if (!randomUser) {
    userID = @"888777";
    userName = @"iOS测试号";
  }
  
  [GBExternalDependency shared].appID = kGrabAppID;
  [GBExternalDependency shared].appSign = kGrabAppSign;
  [GBExternalDependency shared].userID = userID; //randomUserID;
  [GBExternalDependency shared].userName = userName;//[NSString stringWithFormat:@"ios_grab_%d", rdNameSuffix];
  [GBExternalDependency shared].hostUrlString = kGrabHostUrlString;
  [GBExternalDependency shared].avatar = @"https://www.rongshunew.com/uploads/allimg/c190804/15649236322Q20-5bJ18.jpg";
  [GBExternalDependency shared].isTestEnv = YES;
}

@end
