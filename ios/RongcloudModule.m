//
//  RongcloudModule.m
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
// RongcloudModule.h
#import "RongcloudModule.h"

@implementation RongcloudModule

// To export a module named CalendarManager
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initIMSDK:(NSString *)appId)
{
  
    [[RCIM sharedRCIM] initWithAppKey:appId];
    [RCIM sharedRCIM].connectionStatusDelegate = self;
    [RCIM sharedRCIM].receiveMessageDelegate = self;
    [RCIM sharedRCIM].userInfoDataSource = self;

}

- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{
    
}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {

}

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    [RCDUserInfoAPI getUserInfo:userId
                       complete:^(RCUserInfo *userInfo) {
                           if (completion) {
                               completion(userInfo);
                           }
                       }];
}


RCT_EXPORT_METHOD(connectIM:(NSString *)token resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    RCTLogInfo(@"initIMSDK : token =>  %@", token);
    [[RCIM sharedRCIM] connectWithToken:token
                               dbOpened:^(RCDBErrorCode code) {}
                                success:^(NSString *userId) {
        RCTLogInfo(@"connectWithToken success %@", userId);
        resolve(userId);
    }
                                  error:^(RCConnectErrorCode code) {
        NSLog(@"connectWithToken error %ld", (long)code);
        NSString *codeStr = [NSString stringWithFormat:@"%l", code];
        reject(codeStr, @"error", nil);
    }];
}

RCT_EXPORT_METHOD(disconnectIM){
    [[RCIM sharedRCIM] disconnect:YES];
}

RCT_EXPORT_METHOD(getConversationList)
{
    NSArray *conversationList = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE)]];
    
}

RCT_EXPORT_METHOD(showHideContainer:(BOOL)isShow){
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshChatList" object:nil];
}

RCT_EXPORT_METHOD(startConversation:(NSString *)targetId targetName: (NSString *)targetName){
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] initWithConversationType:ConversationType_PRIVATE targetId:targetId];
    chatVC.title = targetName;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openViewController" object:chatVC];
}

RCT_EXPORT_METHOD(setUserInfo:(NSDictionary *)userInfo){
    RCUserInfo * user = [[RCUserInfo alloc] initWithUserId:[userInfo valueForKey:@"id"] name:[userInfo valueForKey:@"nickname"] portrait:[userInfo valueForKey:@"avatar"]];
}

@end


