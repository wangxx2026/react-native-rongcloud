//
//  RCDUserInfoAPI.h
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#ifndef RCDUserInfoAPI_h
#define RCDUserInfoAPI_h

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

@interface RCDUserInfoAPI : NSObject

+ (void)getUserInfo:(NSString *)userId complete:(void (^)(RCUserInfo *userInfo))completeBlock;



@end

#endif
