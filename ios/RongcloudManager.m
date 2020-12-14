//
//  RongcloudManager.m
//  react-native-rongcloud
//
//  Created by hinjin on 2020/11/30.
//

#import <React/RCTBridgeModule.h>
// 融云SDK start
#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>
// 融云SDK end
#import <React/RCTLog.h>
// RongcloudManager.h
#import "RongcloudManager.h"

@implementation RongcloudManager

// To export a module named CalendarManager
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initIMSDK:(NSString *)token)
{
  RCTLogInfo(@"initIMSDK : token =>  %@", token);
    [[RCIM sharedRCIM] initWithAppKey:@"qd46yzrfqup5f"];

    [[RCIM sharedRCIM] connectWithToken:token
                               dbOpened:^(RCDBErrorCode code) {}
                                success:^(NSString *userId) {
        RCTLogInfo(@"connectWithToken success %@", userId);
    }
                                  error:^(RCConnectErrorCode status) {
        NSLog(@"connectWithToken error %ld", (long)status);
    }];
}

RCT_EXPORT_METHOD(getConversationList)
{
    NSArray *conversationList = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE)]];
    
}
@end


