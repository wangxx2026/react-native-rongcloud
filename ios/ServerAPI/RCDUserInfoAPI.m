//
//  RCDUserInfoAPI.m
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDHTTPUtility.h"
#import "RCDCommonString.h"
#import "RCDUserInfoAPI.h"

@implementation RCDUserInfoAPI

+ (void)getUserInfo:(NSString *)userId complete:(void (^)(RCUserInfo *))completeBlock {
    if (!userId) {
        NSLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:[NSString stringWithFormat:@"user/%@", userId]
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         RCUserInfo *userInfo = [[RCUserInfo alloc] init];
                                         userInfo.userId = userId;
                                         userInfo.name = result.content[@"nickname"];
                                         userInfo.portraitUri = result.content[@"avatar"];
                                         if (completeBlock) {
                                             completeBlock(userInfo);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}
@end
