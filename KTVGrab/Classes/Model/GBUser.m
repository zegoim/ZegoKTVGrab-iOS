//
//  GBUser.m
//  KTVGrab
//
//  Created by Vic on 2022/3/4.
//

#import "GBUser.h"
#import "GBConcreteRespModel.h"
#import "GBRoundGrade.h"

@implementation GBUser

- (void)updateWithUserRespModel:(GBUserRespModel *)model {
  self.userID = model.userID;
  self.userName = model.userName;
  self.avatarURLString = model.avatar;
  self.role = [[GBUserRole alloc] initWithRoleType:model.role];
  self.loginTime = model.loginTime;
  self.micOn = (model.micState == 2);
  self.onstage = (model.onstageState == 2);
  self.micIndex = model.micIndex;
  
  self.grade.grabCount = model.grabSongCount;
  self.grade.passCount = model.grabSongPassCount;
  self.grade.score = model.grabSongTotalScore;
}

- (GBRoundGrade *)grade {
  if (!_grade) {
    _grade = [[GBRoundGrade alloc] init];
  }
  return _grade;
}

- (GBUserRoleType)roleType {
  return self.role.roleType;
}

@end
