//
//  GBConcreteRespModel.m
//  KTVGrab
//
//  Created by Vic on 2022/3/12.
//

#import "GBConcreteRespModel.h"

@implementation GBSongRespModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
  return @{
    @"uniqueID": @"unique_id",
    @"songID": @"song_id",
    @"order": @"order",
    @"songName": @"song_name",
    @"singerName": @"singer_name",
    @"firstPartDuration": @"first_part_duration",
  };
}

@end


@implementation GBUserRespModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
  return @{
    @"userID": @"uid",
    @"userName": @"nick_name",
    @"avatar": @"avatar",
    @"role": @"role",
    @"loginTime": @"login_timestamp",
    @"micState": @"mic",
    @"onstageState": @"onstage_state",
    @"micIndex": @"mic_index",
    @"grabSongCount": @"grab_song_num",
    @"grabSongPassCount": @"grab_song_succeed_num",
    @"grabSongTotalScore": @"grab_song_total_score",
  };
}

@end


@implementation GBRoomRespModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
  return @{
    @"roomID": @"room_id",
    @"status": @"status",
    @"subject": @"subject",
    @"createTime": @"create_time",
    @"onlineCount": @"online_count",
    @"onstageCount": @"on_stage_count",
    @"coverImage": @"cover_img",
    @"creatorID": @"creator_id",
    @"creatorAvatar": @"creator_avatar",
    @"creatorName": @"creator_name",
    @"rounds": @"max_round",
    @"curRound": @"current_round",
    @"songsPerRound": @"song_number_per_round",
    @"songsThisRound": @"song_number_this_round",
    @"singerID": @"singer_uid",
    @"curSongID": @"current_song_id",
    @"curSongIndex": @"current_song_index",
    @"singScore": @"sing_score",
    @"isSingerPass": @"is_singer_pass",
    @"songList": @"song_info_list",
    @"userList": @"user_info_list",
    @"maxMicNumber": @"max_mic",
  };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{
    @"songList": GBSongRespModel.class,
    @"userList": GBUserRespModel.class,
  };
}

@end
