//
//  GBRoomInfo.m
//  KTVGrab
//
//  Created by Vic on 2022/3/13.
//

#import "GBRoomInfo.h"

//Model
#import "GBConcreteRespModel.h"
#import "GBUser.h"
#import "GBSongPlay.h"

@implementation GBRoomInfo

- (instancetype)init {
  self = [super init];
  if (self) {
    _roomName = @"默认房间名称";
  }
  return self;
}

- (void)updateWithRoomRespModel:(GBRoomRespModel *)rsp {
  
  self.roomID = rsp.roomID;
  self.roomName = rsp.subject;
  self.imgURLString = rsp.coverImage;
  self.userOnlineCount = rsp.onlineCount;
  self.createTime = rsp.createTime;
  self.userOnlineCount = rsp.onlineCount;
  self.userOnstageCount = rsp.onstageCount;
  self.roomState = rsp.status;
  self.rounds = rsp.rounds;
  self.curRound = rsp.curRound;
  self.songsPerRound = rsp.songsPerRound;
  self.songsThisRound = rsp.songsThisRound;
  self.curSongIndex = rsp.curSongIndex;
  self.curPlayerID = rsp.singerID;
  self.curSongID = rsp.curSongID;
  self.singScore = rsp.singScore;
  self.isSingerPass = rsp.isSingerPass == 2;
  self.seatsCount = rsp.maxMicNumber;
  
  NSMutableArray *songList = [NSMutableArray array];
  for (GBSongRespModel *model in rsp.songList) {
    GBSongPlay *songInfo = [[GBSongPlay alloc] init];
    [songInfo updateWithSongRespModel:model];
    [songList addObject:songInfo];
  }
  self.songPlays = songList.copy;
  
  NSMutableArray *userList = [NSMutableArray array];
  for (GBUserRespModel *model in rsp.userList) {
    GBUser *user = [[GBUser alloc] init];
    [user updateWithUserRespModel:model];
    [userList addObject:user];
  }
  self.roomUsers = userList.copy;
}

@end
