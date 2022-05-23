//
//  ZIMError+GB.m
//  KTVGrab
//
//  Created by Vic on 2022/3/9.
//

#import "ZIMError+GB.h"

@implementation ZIMError (GB)

- (NSString *)debugDescription {
  ZIMErrorCode errorCode = self.code;
  NSString *errorMsg = self.message;
  return [NSString stringWithFormat:@"code:%lu, description: %@", (unsigned long)errorCode, errorMsg];
}

@end
