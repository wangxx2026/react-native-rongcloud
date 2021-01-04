//
//  RCDChatViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDChatViewController.h"

#import "RCDCommonString.h"
#import "RCDCommonDefine.h"

/*******************实时位置共享***************/
#import <objc/runtime.h>
static const char *kRealTimeLocationKey = "kRealTimeLocationKey";
static const char *kRealTimeLocationStatusViewKey = "kRealTimeLocationStatusViewKey";

#define PLUGIN_BOARD_ITEM_POKE_TAG 20000

@interface RCChatSessionInputBarControl ()
@property (nonatomic, assign) BOOL burnMessageMode;
@end
;

@interface RCDChatViewController () <RCMessageCellDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL loading;

@end

@implementation RCDChatViewController

#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    int defalutHistoryMessageCount = (int)[DEFAULTS integerForKey:RCDChatroomDefalutHistoryMessageCountKey];
    if (defalutHistoryMessageCount >= -1 && defalutHistoryMessageCount <= 50) {
        self.defaultHistoryMessageCountOfChatRoom = defalutHistoryMessageCount;
    }
    return self;
}

- (id)initWithConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId {
    self = [super initWithConversationType:conversationType targetId:targetId];
    int defalutHistoryMessageCount = (int)[DEFAULTS integerForKey:RCDChatroomDefalutHistoryMessageCountKey];
    if (defalutHistoryMessageCount >= -1 && defalutHistoryMessageCount <= 50) {
        self.defaultHistoryMessageCountOfChatRoom = defalutHistoryMessageCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;

    self.loading = NO;

    ///注册自定义测试消息Cell
    self.enableSaveNewPhotoToLocalSystem = YES;
    [self notifyUpdateUnreadMessageCount];

    [self addNotifications];
    //    [self addToolbarItems];
    //    self.enableContinuousReadUnreadVoice = YES;//开启语音连读功能

    [self handleChatSessionInputBarControlDemo];
    [self insertMessageDemo];
    [self addEmoticonTabDemo];
    [self setupChatBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshTitle];
    self.isShow = YES;
    RCConversation *conver = [[RCConversation alloc] init];
    conver.conversationType = self.conversationType;
    conver.targetId = self.targetId;
    
    //    [self.chatSessionInputBarControl updateStatus:self.chatSessionInputBarControl.currentBottomBarStatus
    //    animated:NO];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    self.isShow = NO;
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [self updateSubviews:size];
        }];
}

- (void)updateSubviews:(CGSize)size {
    
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)inputTextView:(UITextView *)inputTextView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
    [super inputTextView:inputTextView shouldChangeTextInRange:range replacementText:text];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - over methods
- (void)didTapMessageCell:(RCMessageModel *)model {
    [super didTapMessageCell:model];
}

- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(RCMessageModel *)model {
    NSArray<UIMenuItem *> *menuList = [[super getLongTouchMessageCellMenuList:model] mutableCopy];
    /*
     在这里添加删除菜单。
     [menuList enumerateObjectsUsingBlock:^(UIMenuItem * _Nonnull obj, NSUInteger
     idx, BOOL * _Nonnull stop) {
     if ([obj.title isEqualToString:@"删除"] || [obj.title
     isEqualToString:@"delete"]) {
     [menuList removeObjectAtIndex:idx];
     *stop = YES;
     }
     }];

     UIMenuItem *forwardItem = [[UIMenuItem alloc] initWithTitle:@"转发"
     action:@selector(onForwardMessage:)];
     [menuList addObject:forwardItem];

     如果您不需要修改，不用重写此方法，或者直接return［super
     getLongTouchMessageCellMenuList:model]。
     */
    NSMutableArray *list = menuList.mutableCopy;
    
    return list.copy;
}

- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageContent {
    //可以在这里修改将要发送的消息
    if ([messageContent isMemberOfClass:[RCTextMessage class]]) {
        // RCTextMessage *textMsg = (RCTextMessage *)messageContent;
        // textMsg.extra = @"";
    }
    if (messageContent.mentionedInfo && messageContent.mentionedInfo.userIdList) {
        for (int i = 0; i < messageContent.mentionedInfo.userIdList.count; i++) {
            NSString *userId = messageContent.mentionedInfo.userIdList[i];
            if ([userId isEqualToString:RCDMetionAllUsetId]) {
                messageContent.mentionedInfo.type = RC_Mentioned_All;
                messageContent.mentionedInfo.userIdList = nil;
                break;
            }
        }
    }
    return messageContent;
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view {
    [super didLongTouchMessageCell:model inView:view];
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  更新左上角未读消息数
 */
- (void)notifyUpdateUnreadMessageCount {
    if (self.allowsMessageCellSelection) {
        [super notifyUpdateUnreadMessageCount];
        return;
    }
    rcd_dispatch_main_async_safe(^{
        [self setRightNavigationItems];
    });
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage {
    //保存图片
    UIImage *image = newImage;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
    

#pragma mark - target action
/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)rightBarButtonItemClicked:(id)sender {
    if (ConversationType_APPSERVICE == self.conversationType ||
               ConversationType_PUBLICSERVICE == self.conversationType) {
        RCPublicServiceProfile *serviceProfile =
            [[RCIMClient sharedRCIMClient] getPublicServiceProfile:(RCPublicServiceType)self.conversationType
                                                   publicServiceId:self.targetId];

        RCPublicServiceProfileViewController *infoVC = [[RCPublicServiceProfileViewController alloc] init];
        infoVC.serviceProfile = serviceProfile;
        infoVC.fromConversation = YES;
        [self.navigationController pushViewController:infoVC animated:YES];
    }
}

//和上面的方法相对应，在别的页面弹出键盘导致聊天页面输入状态改变需要及时改变回来
- (void)keyboardWillHideNotification:(NSNotification *)notification {
    if (!self.chatSessionInputBarControl.inputTextView.isFirstResponder) {
        [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
    }
}

- (void)updateForSharedMessageInsertSuccess:(NSNotification *)notification {
    RCMessage *message = notification.object;
    if (message.conversationType == self.conversationType && [message.targetId isEqualToString:self.targetId]) {
        [self appendAndDisplayMessage:message];
    }
}

- (void)updateTitleForGroup:(NSNotification *)notification {
    NSString *groupId = notification.object;
    if ([groupId isEqualToString:self.targetId]) {
        [self refreshTitle];
    }
}

- (void)didGroupMemberUpdateNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.object;
    if ([dic[@"targetId"] isEqualToString:self.targetId]) {
        [self setRightNavigationItems];
    }
}


#pragma mark - Demo
- (void)handleChatSessionInputBarControlDemo {
    //    self.chatSessionInputBarControl.hidden = YES;
    //    CGRect intputTextRect = self.conversationMessageCollectionView.frame;
    //    intputTextRect.size.height = intputTextRect.size.height+50;
    //    [self.conversationMessageCollectionView setFrame:intputTextRect];
    //    [self scrollToBottomAnimated:YES];
    /***********如何自定义面板功能***********************
     //     自定义面板功能首先要继承RCConversationViewController，如现在所在的这个文件。
     //     然后在viewDidLoad函数的super函数之后去编辑按钮：
     //     插入到指定位置的方法如下：
     [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:imagePic
     title:title
     atIndex:0
     tag:101];
     删除指定位置的方法：
     [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:0];
     删除指定标签的方法：
     [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:101];
     删除所有：
     [self.chatSessionInputBarControl.pluginBoardView removeAllItems];
     更换现有扩展项的图标和标题:
     [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:0 image:newImage title:newTitle];
     或者根据tag来更换
     [self.chatSessionInputBarControl.pluginBoardView updateItemWithTag:101 image:newImage title:newTitle];
     以上所有的接口都在RCPluginBoardView.h可以查到。

     当编辑完扩展功能后，下一步就是要实现对扩展功能事件的处理，放开被注掉的函数
     pluginBoardView:clickedItemWithTag:
     在super之后加上自己的处理。

     */

    //默认输入类型为语音
    // self.defaultInputType = RCChatSessionInputBarInputExtention;
    if ([self.targetId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_VOIP_TAG];
        [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_VIDEO_VOIP_TAG];
    }
}

- (void)insertMessageDemo {
    /***********如何在会话页面插入提醒消息***********************

     RCInformationNotificationMessage *warningMsg =
     [RCInformationNotificationMessage
     notificationWithMessage:@"请不要轻易给陌生人汇钱！" extra:nil];
     BOOL saveToDB = NO;  //是否保存到数据库中
     RCMessage *savedMsg ;
     if (saveToDB) {
     savedMsg = [[RCIMClient sharedRCIMClient]
     insertOutgoingMessage:self.conversationType targetId:self.targetId
     sentStatus:SentStatus_SENT content:warningMsg];
     } else {
     savedMsg =[[RCMessage alloc] initWithType:self.conversationType
     targetId:self.targetId direction:MessageDirection_SEND messageId:-1
     content:warningMsg];//注意messageId要设置为－1
     }
     [self appendAndDisplayMessage:savedMsg];
     */
}

- (void)addEmoticonTabDemo {
    //  //表情面板添加自定义表情包
    //  UIImage *icon = [RCKitUtility imageNamed:@"emoji_btn_normal"
    //                                  ofBundle:@"RongCloud.bundle"];
    //  RCDCustomerEmoticonTab *emoticonTab1 = [RCDCustomerEmoticonTab new];
    //  emoticonTab1.identify = @"1";
    //  emoticonTab1.image = icon;
    //  emoticonTab1.pageCount = 2;
    //  [self.emojiBoardView addEmojiTab:emoticonTab1];
    //
    //  RCDCustomerEmoticonTab *emoticonTab2 = [RCDCustomerEmoticonTab new];
    //  emoticonTab2.identify = @"2";
    //  emoticonTab2.image = icon;
    //  emoticonTab2.pageCount = 4;
    //  [self.emojiBoardView addEmojiTab:emoticonTab2];
}


- (void)setRightNavigationItem:(UIImage *)image withFrame:(CGRect)frame {
    UIBarButtonItem *rightBtn = [self createContainImage:image imageViewFrame:frame
                                                                        buttonTitle:nil
                                                                         titleColor:nil
                                                                         titleFrame:CGRectZero
                                                                        buttonFrame:frame
                                                                             target:self
                                                                             action:@selector(rightBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}
    
    //初始化包含图片的UIBarButtonItem
-(UIBarButtonItem *)createContainImage:(UIImage *)buttonImage
                              imageViewFrame:(CGRect)imageFrame
                                 buttonTitle:(NSString *)buttonTitle
                                  titleColor:(UIColor *)titleColor
                                  titleFrame:(CGRect)titleFrame
                                 buttonFrame:(CGRect)buttonFrame
                                      target:(id)target
                                      action:(SEL)method {
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] init];
        UIView *view = [[UIView alloc] initWithFrame:buttonFrame];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = buttonFrame;
        UIImageView *image = [[UIImageView alloc] initWithImage:buttonImage];
        image.frame = imageFrame;
        [button addSubview:image];
        if (buttonTitle != nil && titleColor != nil) {
            UILabel *titleText = [[UILabel alloc] initWithFrame:titleFrame];
            titleText.text = buttonTitle;
            [titleText setBackgroundColor:[UIColor clearColor]];
            [titleText setTextColor:titleColor];
            [button addSubview:titleText];
        }
        [button addTarget:target action:method forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:method];
        [view addGestureRecognizer:tap];
        return buttonItem;
    }

- (void)clearHistoryMSG {
    [self.conversationDataRepository removeAllObjects];
    [self.conversationMessageCollectionView reloadData];
}
    
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
}

- (void)refreshTitle {
    if(self.conversationType == ConversationType_PRIVATE){
        RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:self.targetId];
        if (userInfo) {
            self.title = userInfo.name;
        }
    }
}

- (BOOL)stayAfterJoinChatRoomFailed {
    //加入聊天室失败之后，是否还停留在会话界面
    return [DEFAULTS boolForKey:RCDStayAfterJoinChatRoomFailedKey];
}

- (void)alertErrorAndLeft:(NSString *)errorInfo {
    if (![self stayAfterJoinChatRoomFailed]) {
        [super alertErrorAndLeft:errorInfo];
    }
}

- (void)setRightNavigationItems {
    [self setRightNavigationItem:nil withFrame:CGRectZero];
    
}
- (void)addNotifications {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateForSharedMessageInsertSuccess:)
                                                 name:@"RCDSharedMessageInsertSuccess"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onEndForwardMessage:)
                                                 name:@"RCDForwardMessageEnd"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

- (void)setupChatBackground {
    NSString *imageName = [DEFAULTS objectForKey:RCDChatBackgroundKey];
    UIImage *image = [UIImage imageNamed:imageName];
    if ([imageName isEqualToString:RCDChatBackgroundFromAlbum]) {
        NSData *imageData = [DEFAULTS objectForKey:RCDChatBackgroundImageDataKey];
        image = [UIImage imageWithData:imageData];
    }
    if (image) {
        self.conversationMessageCollectionView.backgroundColor = [UIColor clearColor];
        image = [RCKitUtility fixOrientation:image];
        self.view.layer.contents = (id)image.CGImage;
    }
}

#pragma mark - *************消息多选功能:转发、删除*************
/******************消息多选功能:转发、删除**********************/
- (void)addToolbarItems {
    //转发按钮
    UIButton *forwardBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [forwardBtn setImage:[UIImage imageNamed:@"forward_message"] forState:UIControlStateNormal];
    [forwardBtn addTarget:self action:@selector(forwardMessage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *forwardBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:forwardBtn];
    //删除按钮
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [deleteBtn setImage:[RCKitUtility imageNamed:@"delete_message" ofBundle:@"RongCloud.bundle"]
               forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteMessages) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *deleteBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    //按钮间 space
    UIBarButtonItem *spaceItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.messageSelectionToolbar
        setItems:@[ spaceItem, forwardBarButtonItem, spaceItem, deleteBarButtonItem, spaceItem ]
        animated:YES];
}

- (void)deleteMessages {
    for (int i = 0; i < self.selectedMessages.count; i++) {
        [self deleteMessage:self.selectedMessages[i]];
    }
    //置为 NO,将消息 cell 重置为初始状态
    self.allowsMessageCellSelection = NO;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setupChatBackground];
}


- (void)onRealTimeLocationStartFailed:(long)messageId {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
            if (model.messageId == messageId) {
                model.sentStatus = SentStatus_FAILED;
            }
        }
        NSArray *visibleItem = [self.conversationMessageCollectionView indexPathsForVisibleItems];
        for (int i = 0; i < visibleItem.count; i++) {
            NSIndexPath *indexPath = visibleItem[i];
            RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
            if (model.messageId == messageId) {
                [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[ indexPath ]];
            }
        }
    });
}

- (void)onFailUpdateLocation:(NSString *)description {
}


#pragma mark - 加载远端聊天室消息开始
//#pragma mark *************Load More Chatroom History Message From Server*************
////需要开通聊天室消息云端存储功能，调用getRemoteChatroomHistoryMessages接口才可以从服务器获取到聊天室消息的数据
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    //当会话类型是聊天室时，下拉加载消息会调用getRemoteChatroomHistoryMessages接口从服务器拉取聊天室消息
//    if (self.conversationType == ConversationType_CHATROOM) {
//        if (scrollView.contentOffset.y < -15.0f && !self.loading) {
//            self.loading = YES;
//            [self performSelector:@selector(loadMoreChatroomHistoryMessageFromServer) withObject:nil afterDelay:0.4f];
//        }
//    } else {
//        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//    }
//}
//
////从服务器拉取聊天室消息的方法
//- (void)loadMoreChatroomHistoryMessageFromServer {
//    long long recordTime = 0;
//    RCMessageModel *model;
//    if (self.conversationDataRepository.count > 0) {
//        model = [self.conversationDataRepository objectAtIndex:0];
//        recordTime = model.sentTime;
//    }
//    __weak typeof(self) weakSelf = self;
//    [[RCIMClient sharedRCIMClient] getRemoteChatroomHistoryMessages:self.targetId
//        recordTime:recordTime
//        count:20
//        order:RC_Timestamp_Desc
//        success:^(NSArray *messages, long long syncTime) {
//            self.loading = NO;
//            [weakSelf handleMessages:messages];
//        }
//        error:^(RCErrorCode status) {
//            NSLog(@"load remote history message failed(%zd)", status);
//        }];
//}
//
////对于从服务器拉取到的聊天室消息的处理
//- (void)handleMessages:(NSArray *)messages {
//    NSMutableArray *tempMessags = [[NSMutableArray alloc] initWithCapacity:0];
//    for (RCMessage *message in messages) {
//        RCMessageModel *model = [RCMessageModel modelWithMessage:message];
//        [tempMessags addObject:model];
//    }
//    //对去拉取到的消息进行逆序排列
//    NSArray *reversedArray = [[tempMessags reverseObjectEnumerator] allObjects];
//    tempMessags = [reversedArray mutableCopy];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //将逆序排列的消息加入到数据源
//        [tempMessags addObjectsFromArray:self.conversationDataRepository];
//        self.conversationDataRepository = tempMessags;
//        //显示消息发送时间的方法
//        [self figureOutAllConversationDataRepository];
//        [self.conversationMessageCollectionView reloadData];
//        if (self.conversationDataRepository != nil && self.conversationDataRepository.count > 0 &&
//            [self.conversationMessageCollectionView numberOfItemsInSection:0] >= messages.count - 1) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messages.count - 1 inSection:0];
//            [self.conversationMessageCollectionView scrollToItemAtIndexPath:indexPath
//                                                           atScrollPosition:UICollectionViewScrollPositionTop
//                                                                   animated:NO];
//        }
//    });
//}
//
////显示消息发送时间的方法
//- (void)figureOutAllConversationDataRepository {
//    for (int i = 0; i < self.conversationDataRepository.count; i++) {
//        RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
//        if (0 == i) {
//            model.isDisplayMessageTime = YES;
//        } else if (i > 0) {
//            RCMessageModel *pre_model = [self.conversationDataRepository objectAtIndex:i - 1];
//
//            long long previous_time = pre_model.sentTime;
//
//            long long current_time = model.sentTime;
//
//            long long interval =
//                current_time - previous_time > 0 ? current_time - previous_time : previous_time - current_time;
//            if (interval / 1000 <= 3 * 60) {
//                if (model.isDisplayMessageTime && model.cellSize.height > 0) {
//                    CGSize size = model.cellSize;
//                    size.height = model.cellSize.height - 45;
//                    model.cellSize = size;
//                }
//                model.isDisplayMessageTime = NO;
//            } else if (![[[model.content class] getObjectName] isEqualToString:@"RC:OldMsgNtf"]) {
//                if (!model.isDisplayMessageTime && model.cellSize.height > 0) {
//                    CGSize size = model.cellSize;
//                    size.height = model.cellSize.height + 45;
//                    model.cellSize = size;
//                }
//                model.isDisplayMessageTime = YES;
//            }
//        }
//        if ([[[model.content class] getObjectName] isEqualToString:@"RC:OldMsgNtf"]) {
//            model.isDisplayMessageTime = NO;
//        }
//    }
//}
#pragma mark 加载远端聊天室消息结束
@end
