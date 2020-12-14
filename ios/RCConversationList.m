#import "RCConversationList.h"
#import <RongIMKit/RongIMKit.h>
@implementation RCConversationList

RCT_EXPORT_MODULE()

- (RCConversationListViewController *)view
{
    UIView *view = [[UIView alloc] init];
    RCConversationListViewController *conversationListViewController = [[RCConversationListViewController alloc] initWithDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP),@(ConversationType_SYSTEM)] collectionConversationType:@[@(ConversationType_SYSTEM)]];

//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:conversationListViewController];
//        self.window.rootViewController = navigationController;

//    conversationListViewController
    [view addSubview:conversationListViewController.view];
    return view;
}

@end
