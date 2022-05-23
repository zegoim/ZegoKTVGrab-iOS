//
//  GBDemoNavigationVC.m
//  KTVGrab_Example
//
//  Created by Vic on 2022/4/27.
//  Copyright © 2022 Zego. All rights reserved.
//

#import "GBDemoNavigationVC.h"

@interface GBDemoNavigationVC ()

@end

@implementation GBDemoNavigationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIStatusBarStyle)preferredStatusBarStyle {
  return self.topViewController.preferredStatusBarStyle;
}


@end
