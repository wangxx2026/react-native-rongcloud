#import "RongcloudManager.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDChatListViewController.h"
@implementation RongcloudManager

RCT_EXPORT_MODULE(ConversationList)

- (UIView *)view
{
    UIView *view = [[UIView alloc] init];
    self.conversationListVC = [[RCDChatListViewController alloc] initWithDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP),@(ConversationType_SYSTEM)] collectionConversationType:@[@(ConversationType_SYSTEM)]];

//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:conversationListViewController];
//        self.window.rootViewController = navigationController;

//    conversationListViewController
    [view addSubview:self.conversationListVC.view];
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"refreshChatList" object:nil];
    return view;
}

-(void)reloadData{
    [self.conversationListVC refreshConversationTableViewIfNeeded];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
