//
//  FirstViewController.m
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDChatListViewController.h"
#import "RCDChatViewController.h"
#import "UIColor+RCColor.h"
#import "RCDCommonString.h"
//#import "RCDUtilities.h"
#import "RCDCommonDefine.h"
#define HEXCOLOR(rgbValue)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
                green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
                 blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
alpha:1.0]
@interface RCDChatListViewController ()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL isClick;
@end

@implementation RCDChatListViewController
#pragma mark - life cycle
- (id)init {
    self = [super init];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[
            @(ConversationType_PRIVATE),
            @(ConversationType_APPSERVICE),
            @(ConversationType_PUBLICSERVICE),
            @(ConversationType_GROUP),
            @(ConversationType_SYSTEM)
        ]];

        //聚合会话类型
        [self setCollectionConversationType:@[ @(ConversationType_SYSTEM) ]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubviews];
    [self registerNotification];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateSubviews:size];
    }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> context){

        }];
}

- (void)updateSubviews:(CGSize)size {
//    self.searchBar.frame = CGRectMake(0, 0, size.width, 44);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isClick = YES;
    RCUserInfo *groupNotify = [[RCUserInfo alloc] initWithUserId:@"__system__" name:@"" portrait:nil];
    [[RCIM sharedRCIM] refreshUserInfoCache:groupNotify withUserId:@"__system__"];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [self.conversationListTableView indexPathForRowAtPoint:scrollView.contentOffset];
    self.index = indexPath.row;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //恢复conversationListTableView的自动回滚功能。
    self.conversationListTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - over method
/**
 *  点击进入会话页面
 *
 *  @param conversationModelType 会话类型
 *  @param model                 会话数据
 *  @param indexPath             indexPath description
 */
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] initWithConversationType:ConversationType_PRIVATE targetId:model.targetId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openViewController" object:chatVC];
}

//左滑删除
- (void)rcConversationListTableView:(UITableView *)tableView
                 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                  forRowAtIndexPath:(NSIndexPath *)indexPath {
    //可以从数据库删除数据
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_SYSTEM targetId:model.targetId];
    [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
    [self.conversationListTableView reloadData];
}

//高度
- (CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67.0f;
}

//*********************插入自定义Cell*********************//

//点击头像功能和点击cell功能同步
- (void)didTapCellPortrait:(RCConversationModel *)model {
    [self onSelectedTableRow:model.conversationModelType conversationModel:model atIndexPath:nil];
}

- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    /*
    //会话有新消息通知的时候显示数字提醒，设置为NO,不显示数字只显示红点
    if (model.conversationType == ConversationType_PRIVATE) {
        ((RCConversationCell *)cell).isShowNotificationNumber = NO;
    }*/
}

//收到消息监听
- (void)didReceiveMessageNotification:(NSNotification *)notification {
    __weak typeof(self) blockSelf_ = self;
    
    //调用父类刷新未读消息数
    [super didReceiveMessageNotification:notification];
}

#pragma mark - target action

- (void)gotoNextConversation {
    NSUInteger i;
    //设置contentInset是为了滚动到底部的时候，避免conversationListTableView自动回滚。
    self.conversationListTableView.contentInset =
        UIEdgeInsetsMake(0, 0, self.conversationListTableView.frame.size.height, 0);
    for (i = self.index + 1; i < self.conversationListDataSource.count; i++) {
        RCConversationModel *model = self.conversationListDataSource[i];
        if (model.unreadMessageCount > 0) {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            self.index = i;
            [self.conversationListTableView scrollToRowAtIndexPath:scrollIndexPath
                                                  atScrollPosition:UITableViewScrollPositionTop
                                                          animated:YES];
            break;
        }
    }
    //滚动到起始位置
    if (i >= self.conversationListDataSource.count) {
        //    self.conversationListTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        for (i = 0; i < self.conversationListDataSource.count; i++) {
            RCConversationModel *model = self.conversationListDataSource[i];
            if (model.unreadMessageCount > 0) {
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                self.index = i;
                [self.conversationListTableView scrollToRowAtIndexPath:scrollIndexPath
                                                      atScrollPosition:UITableViewScrollPositionTop
                                                              animated:YES];
                break;
            }
        }
    }
}

- (void)updateForSharedMessageInsertSuccess {
    [self refreshConversationTableViewIfNeeded];
}

- (void)refreshCell:(NSNotification *)notify {
    /*
     NSString *row = [notify object];
     RCConversationModel *model = [self.conversationListDataSource objectAtIndex:[row intValue]];
     model.unreadMessageCount = 0;
     NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[row integerValue] inSection:0];
     dispatch_async(dispatch_get_main_queue(), ^{
     [self.conversationListTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil]
     withRowAnimation:UITableViewRowAnimationNone];
     });
     */
    [self refreshConversationTableViewIfNeeded];
}

#pragma mark - helper
- (void)registerNotification {
    //接收定位到未读数会话的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoNextConversation)
                                                 name:@"GotoNextConversation"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateForSharedMessageInsertSuccess)
                                                 name:@"RCDSharedMessageInsertSuccess"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCell:)
                                                 name:@"RefreshConversationList"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushToQRScan)
                                                 name:RCDOpenQRCodeUrlNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadgeForTabBarItem)
                                                 name:RCDContactsRequestKey
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didClearMessage)
                                                 name:RCDGroupClearMessageKey
                                               object:nil];
}

- (void)didClearMessage {
    [self refreshConversationTableViewIfNeeded];
}

/**
 *  发起聊天
 *
 *  @param sender sender description
 */
- (void)pushChat:(id)sender {
//    RCDContactSelectedTableViewController *contactSelectedVC =
//        [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"start_chatting")
//                                           isAllowsMultipleSelection:NO];
//    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

- (void)pushChatVC:(RCConversationModel *)model {
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.conversationType = model.conversationType;
    chatVC.targetId = model.targetId;
    chatVC.userName = model.conversationTitle;
    chatVC.title = model.conversationTitle;
    
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)initSubviews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    //设置tableView样式
//    self.conversationListTableView.separatorColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xdfdfdf) darkColor:HEXCOLOR(0x1a1a1a)];
    self.conversationListTableView.tableFooterView = [UIView new];
    self.conversationListTableView.tableHeaderView = self.headerView;
    // 设置在NavigatorBar中显示连接中的提示
    self.showConnectingStatusOnNavigatorBar = YES;
    //定位未读数会话
    self.index = 0;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.conversationListTableView.frame.size.width, 0)];
        if (@available(iOS 11.0, *)) {
            _headerView.frame = CGRectMake(0, 0, self.conversationListTableView.frame.size.width, 0);
        }
    }
    return _headerView;
}

@end
