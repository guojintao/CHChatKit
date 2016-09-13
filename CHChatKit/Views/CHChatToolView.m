//
//  CHChatToolView.m
//  CHChatDemo
//
//  Created by Chasusson on 15/11/14.
//  Copyright © 2015年 Chausson. All rights reserved.
//
#define KCONTENT_FONT 15
#define KINPUTVIEW_HEIGHT 50
#define KASSIGANTVIEW_HEIGHT 216
#define KBUTTON_SIZE 35
#define KGAP 5
#define CHATTOOL_FILE_NAME @"ChatResourse"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "CHAssistanceHandler.h"
#import "CHChatToolView.h"
#import "ChatAssistanceView.h"
#import "CHChatConfiguration.h"
#import "CHChatBusinessCommnd.h"
#import "CHChatTextView.h"
#import "UUProgressHUD.h"
#import "FaceBoard.h"
#import "NSString+AutoSize.h"
#import "Masonry.h"

typedef NS_ENUM(NSUInteger, CHChatToolSate) {
    CHChatSelectedNone,
    CHChatSelectedText,
    CHChatSelectedEmoji,
    CHChatSelectedVoice,
    CHChatSelectedAssistance
};
@interface CHChatToolView ()<UITextViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate,FaceBoardDelegate,ChatAssistanceViewDelegate>
@property (strong ,nonatomic) ChatAssistanceView *assistanceView;
@property (strong ,nonatomic) FaceBoard *faceBoard;
@property (strong ,nonatomic) UIImageView *backgroundView;
@property (strong ,nonatomic) UIButton *messageBtn;
@property (strong ,nonatomic) UIButton *moreItemBtn;
@property (strong ,nonatomic) UIButton *emojiBtn;
@property (strong ,nonatomic) UIButton *talkBtn;
@property (strong ,nonatomic) UIView *contentView;
@property (strong ,nonatomic) UIView *chatWindowView;
@property (strong ,nonatomic) CHChatTextView *contentTextView;
@property (strong ,nonatomic) CHAssistanceHandler *handler;
@property (strong ,nonatomic) UIImageView *contentBackground;
@property (weak   ,nonatomic) NSObject<CHChatToolViewKeyboardProtcol> *observer;
@property (assign ,nonatomic) CGRect hiddenKeyboardRect;
@property (assign ,nonatomic) CGRect showkeyboardRect;
@property (strong ,nonatomic) AVAudioRecorder *recorder;
@property (strong ,nonatomic) NSTimer *recordTimer;// 定时器
@property (assign ,nonatomic) CGFloat recordTime;// 录音时间
@property (assign ,nonatomic) CHChatToolSate currentState;// 聊天工具当前选择的按钮
@property (assign ,nonatomic) CGFloat currentScreenHeight;// 当前页面高度



@end
@implementation CHChatToolView

- (instancetype)initWithObserver:(NSObject<CHChatToolViewKeyboardProtcol>*)object{
    self = [super init];
    if (self) {

         self.currentScreenHeight = [UIScreen mainScreen].bounds.size.height;
    
        if (object) {
              _observer = object;
        }
        if (![CHChatConfiguration standardChatDefaults].fitToNaviation) {
            self.currentScreenHeight -= 64;
        }
       // self.hidden = YES;
        self.frame = CGRectMake(0,self.currentScreenHeight-KINPUTVIEW_HEIGHT, [UIScreen mainScreen].bounds.size.width, (KINPUTVIEW_HEIGHT+KASSIGANTVIEW_HEIGHT));
            
        self.backgroundColor = [CHChatConfiguration standardChatDefaults].toolContentBackground;
        [self initInputView];
        [self addSubviewsAndAutoLayout];
        [self maekConstaints];
        [self registerForKeyboardNotifications];
    }
    return self;
}
#pragma mark Layoutsubviews
// 约束当前视图
// TO DO
- (void)autoLayoutView{
    self.hidden = NO;
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.equalTo(@(KINPUTVIEW_HEIGHT + KASSIGANTVIEW_HEIGHT));
        make.bottom.offset(0);

    }];
}
- (void)initInputView{
    _chatWindowView = [[UIView alloc]init];
    _messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_messageBtn setBackgroundImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
    [_messageBtn setBackgroundImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateSelected];
    [_messageBtn setBackgroundImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
    [_messageBtn addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
    _moreItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreItemBtn setBackgroundImage:[UIImage imageNamed:@"mail_add_normal"] forState:UIControlStateNormal];
    [_moreItemBtn addTarget:self action:@selector(moreItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_emojiBtn setBackgroundImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
    [_emojiBtn setBackgroundImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateSelected];
    [_emojiBtn setBackgroundImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
    [_emojiBtn addTarget:self action:@selector(emojiAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _contentView = [[UIView alloc]init];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentTextView = [[CHChatTextView alloc]init];
    _contentTextView.keyboardAppearance = [CHChatConfiguration standardChatDefaults].keyboardAppearance;
    _contentBackground = [[UIImageView alloc]init];
    UIImage* img= [UIImage imageNamed:@"Action_Sheet_Normal_New"];//原图
    _contentBackground.image = img;
    UIEdgeInsets  edge = UIEdgeInsetsMake(10, 30, 10,30);
         //UIImageResizingModeStretch：拉伸模式，通过拉伸UIEdgeInsets指定的矩形区域来填充图片
         //UIImageResizingModeTile：平铺模式，通过重复显示UIEdgeInsets指定的矩形区域来填充图
    img= [img resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
    _contentBackground.image= img;
    _contentBackground.backgroundColor = self.backgroundColor;
    _contentTextView.font = [UIFont systemFontOfSize:KCONTENT_FONT];
    _contentTextView.delegate = self;
    _contentTextView.backgroundColor = [CHChatConfiguration standardChatDefaults].toolInputViewBackground;
    _contentTextView.returnKeyType = UIReturnKeySend;
    
    _faceBoard = [[FaceBoard alloc] init];
    _faceBoard.FaceDelegate = self;
    _faceBoard.backgroundColor = self.backgroundColor;
    _assistanceView = [[ChatAssistanceView alloc] init];
    _assistanceView.delegate = self;
    _assistanceView.backgroundColor = self.backgroundColor;
    

    _talkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_talkBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [_talkBtn setTitle:@"松开结束" forState:UIControlStateHighlighted];
    [_talkBtn setTitleColor:[UIColor colorWithRed:65.0/ 255.0 green:65.0/255.0 blue:65.0 /255.0  alpha:1] forState:UIControlStateNormal];
    [_talkBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    _talkBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_talkBtn setBackgroundColor:[UIColor clearColor]];
    [_talkBtn addTarget:self action:@selector(beginRecordVioce:) forControlEvents:UIControlEventTouchDown];
    [_talkBtn addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
    [_talkBtn addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [_talkBtn addTarget:self action:@selector(remindDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [_talkBtn addTarget:self action:@selector(remindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    
    [_talkBtn setHidden:TRUE];


}

- (void)addSubviewsAndAutoLayout{

    [_contentView addSubview:_contentBackground];
    [_chatWindowView addSubview:_messageBtn];
    [_contentView addSubview:_talkBtn];
    [_contentView addSubview:_contentTextView];

    [_chatWindowView addSubview:_moreItemBtn];
    [_chatWindowView addSubview:_emojiBtn];
    [_chatWindowView addSubview:_contentView];
    [self addSubview:_chatWindowView];
    [self addSubview:_assistanceView];
    [self addSubview:_faceBoard];
    



}
- (void)maekConstaints{
    CGFloat messageWH = [CHChatConfiguration standardChatDefaults].allowRecordVoice?KBUTTON_SIZE:0;
    CGFloat emojiWH = [CHChatConfiguration standardChatDefaults].allowEmoji?KBUTTON_SIZE:0;
    CGFloat assisatanceWH = [CHChatConfiguration standardChatDefaults].allowAssistance?KBUTTON_SIZE:0;

    UIEdgeInsets talkPadding = UIEdgeInsetsMake(KGAP, KGAP, KGAP, KGAP);
    [_talkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.with.insets(talkPadding);
    }];
    [_chatWindowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.with.offset(0);
        make.height.equalTo(@(KINPUTVIEW_HEIGHT));
    }];
    [_messageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(KGAP);
        make.bottom.equalTo(_chatWindowView).offset(-KGAP*1.5);
        make.height.and.width.equalTo(@(messageWH));
    }];
    [_moreItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_messageBtn.mas_bottom);
        make.height.and.width.equalTo(@(assisatanceWH));
        make.right.equalTo(self).offset(-KGAP);
    }];
    [_emojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_messageBtn.mas_bottom);
        make.height.and.width.equalTo(@(emojiWH));
        make.right.equalTo(_moreItemBtn.mas_left).offset(-KGAP);
    }];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(KGAP);
        make.bottom.offset(-KGAP);
        //        make.height.equalTo(@(KINPUTVIEW_HEIGHT-KGAP*2));
        make.left.equalTo(_messageBtn.mas_right).offset(KGAP*2);
        make.right.equalTo(_emojiBtn.mas_left).offset(-KGAP*2);
    }];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(3, KGAP, 3, KGAP);
    [_contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.with.insets(padding);
        
    }];
    
    
    [_contentBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_contentView).with.offset(0);
    }];

    [_assistanceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_chatWindowView.mas_bottom).with.offset(0);
        make.left.and.right.offset(0);
        make.height.equalTo(@(KASSIGANTVIEW_HEIGHT));
        
    }];
    _faceBoard.frame = CGRectMake(0, KINPUTVIEW_HEIGHT+KASSIGANTVIEW_HEIGHT, self.frame.size.width, KASSIGANTVIEW_HEIGHT);

}

#pragma mark 注册通知
- (void)registerForKeyboardNotifications{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}
#pragma mark 键盘显示的监听方法
-(void)keyboardWillShow:(NSNotification *)notif
{
  
    // 获取键盘的位置和大小
    CGRect keyboardBounds;
    [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notif.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGFloat height =  self.currentScreenHeight - keyboardBounds.size.height - KINPUTVIEW_HEIGHT;
    CGRect rect = self.frame;
    rect.origin.y =  height;
    if (keyboardBounds.size.height == 0) {
        return;
    }
    [self movePostionWithY:height duration:[duration doubleValue] curve:[curve intValue]];
    if ([_observer respondsToSelector:@selector(chatKeyboardWillShow)]) {
        [_observer chatKeyboardWillShow];
    }
}
- (void)keyboardDidShow:(NSNotification *) note{
    if ([_observer respondsToSelector:@selector(chatKeyboardDidShow)]) {
        [_observer chatKeyboardDidShow];
    }
}
#pragma mark 键盘隐藏的监听方法
-(void)keyboardWillHide:(NSNotification *) note
{
    
  
    
//    NSLog(@"%@",NSStringFromCGRect(self.frame));
  
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGFloat height  = self.currentScreenHeight  - KINPUTVIEW_HEIGHT;
 // 调整各个状态的高度
    switch (_currentState) {
        case CHChatSelectedAssistance:
            height = self.currentScreenHeight  - self.frame.size.height;
            break;
        case CHChatSelectedEmoji:
            height = self.currentScreenHeight  - self.frame.size.height;
            break;
        case CHChatSelectedVoice:
            height = self.currentScreenHeight  - KINPUTVIEW_HEIGHT;
            break;
            
        default:
            break;
    }
    [self movePostionWithY:height duration:[duration doubleValue] curve:[curve intValue]];
    if ([_observer respondsToSelector:@selector(chatKeyboardWillHide)]) {
        [_observer chatKeyboardWillHide];
    }
}
- (void)keyboardDidHide:(NSNotification *) note{
    
    if ([_observer respondsToSelector:@selector(chatKeyboardDidHide)]) {
        [_observer chatKeyboardDidHide];
    }
}
#pragma mark faceDelegat
//点击表情返回的字符
-(void)clickFaceBoard:(NSString *)string
{
       _contentTextView.text = [NSString stringWithFormat:@"%@%@",_contentTextView.text,string];
    
}



#pragma mark Button_Action
- (void)messageAction:(UIButton *)sender{
    if (sender.selected) {
        // 语音输入
        self.currentState = CHChatSelectedText;
    
        [sender setBackgroundImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        sender.selected = NO;
        //选中状态事件
    }else{
        // 文字输入
        self.currentState = CHChatSelectedVoice;
   
        [sender setBackgroundImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        //未选中状态事件
        sender.selected = YES;
    }
    
}

- (void)moreItemAction:(UIButton *)sender{
    if (sender.selected) {
        self.currentState = CHChatSelectedText;
        sender.selected = NO;
    }else{
        self.currentState = CHChatSelectedAssistance;
        sender.selected = YES;
    }
}

- (void)emojiAction:(UIButton *)sender{

    if (sender.selected) {
         self.currentState = CHChatSelectedText;
        [sender setBackgroundImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        sender.selected = NO;
    }else{
         self.currentState = CHChatSelectedEmoji;
   
        [sender setBackgroundImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        sender.selected = YES;
    }


}

#pragma mark Private
- (void)setCurrentState:(CHChatToolSate)currentState{
    _currentState = currentState;
    CGFloat inputHeight = self.currentScreenHeight  - self.frame.size.height;
    CGFloat outputHeight = self.currentScreenHeight - KINPUTVIEW_HEIGHT;
    // 弹出的高度
    
    switch (currentState) {
        case CHChatSelectedText:
        [self moveEmojiWithY:KINPUTVIEW_HEIGHT+KASSIGANTVIEW_HEIGHT];
         [_contentTextView  becomeFirstResponder];
        
    
            break;
        case CHChatSelectedAssistance:
            
            [self moveEmojiWithY:KINPUTVIEW_HEIGHT+KASSIGANTVIEW_HEIGHT];
            _contentTextView.hidden = FALSE;
            _talkBtn.hidden = TRUE;
            _emojiBtn.selected = NO;
            _messageBtn.selected = NO;
            [self movePostionWithY:inputHeight duration:0.25 curve:0.25];
            [_contentTextView resignFirstResponder];
          
            break;
        case CHChatSelectedVoice:
            _contentTextView.hidden = TRUE;
            _talkBtn.hidden = FALSE;
            _emojiBtn.selected = NO;
            _moreItemBtn.selected = NO;
            [self movePostionWithY:outputHeight duration:0.25 curve:0.25];
            [_contentTextView resignFirstResponder];

            break;
        case CHChatSelectedEmoji:
            [self moveEmojiWithY:KINPUTVIEW_HEIGHT];
            _contentTextView.hidden = FALSE;
            _talkBtn.hidden = TRUE;
            _moreItemBtn.selected = NO;
            _messageBtn.selected = NO;
            [self movePostionWithY:inputHeight duration:0.25 curve:0.25];
            [_contentTextView resignFirstResponder];
        
     
            break;
        case CHChatSelectedNone:
            [self moveEmojiWithY:KINPUTVIEW_HEIGHT+KASSIGANTVIEW_HEIGHT];
            [_contentTextView resignFirstResponder];
            _contentTextView.hidden = FALSE;
            _talkBtn.hidden = TRUE;
            _emojiBtn.selected = NO;
            _moreItemBtn.selected = NO;
            
            break;
            
        default:
            break;
    }
    if ([_observer respondsToSelector:@selector(chatInputView)]) {
        [_observer chatInputView];
    }

}
- (void)moveEmojiWithY:(CGFloat)y{
    CGRect rect = _faceBoard.frame;
    rect.origin.y =  y;
    [UIView animateWithDuration:0.4f animations:^{
        _faceBoard.frame = rect;
    }];
}
- (void)movePostionWithY:(CGFloat )y
                duration:(CGFloat)duration
                   curve:(CGFloat)curve{
    CGRect rect = self.frame;
    rect.origin.y =  y;
    // 动画改变位置
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
        // 更改输入框的位置
        self.frame = rect;
        
    }];
}
#pragma mark AssistanceDelegate
- (void)didSelectedItem:(NSInteger)index{

    
    //__weak typeof(self) weakSelf = self;
    
    switch (index) {
        case 0:{
            [self.handler pickPhotoWihtLibraryPicker:_observer completion:^(UIImage *image) {
                if ([_observer respondsToSelector:@selector(sendImage:)]) {
                    [_observer sendImage:image];
                }
            }];
            
        } break;
        case 1:{
            [self.handler pickPhotoWihtCameraPicker:_observer completion:^(UIImage *image){
                if ([_observer respondsToSelector:@selector(sendImage:)]) {
                    [_observer sendImage:image];
                }
            }];
            
        } break;
            
        default:
            break;
    }
}
- (CHAssistanceHandler *)handler{
    if (!_handler) {
        _handler = [[CHAssistanceHandler alloc]init];
    }
    return _handler;
}
#pragma mark 开始录音
- (void)beginRecordVioce:(UIButton *)button{
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (session == nil) {
        NSLog(@"Error creating session: %@",[sessionError description]);
    }else{
        [session setActive:YES error:nil];
    }
    // 录音设置
    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    // 设置录音格式
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    // 设置采样率
    [recordSetting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
    // 录音通道
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    // 线性采样率
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    // 录音质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/arm.wav"];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path] settings:recordSetting error:nil];
    self.recorder.delegate = self;
    [self.recorder prepareToRecord];
    [self.recorder record];
    
    self.recordTime = 0;
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
    [UUProgressHUD show];
}

- (void)endRecordVoice:(UIButton *)button
{
    [UUProgressHUD dismissWithSuccess:nil];
    [self.recorder stop];
}

- (void)cancelRecordVoice:(UIButton *)button
{
    [self.recorder stop];
    [self.recorder deleteRecording];
    [UUProgressHUD dismissWithError:@"取消"];
}

- (void)remindDragExit:(UIButton *)button
{
    [UUProgressHUD changeSubTitle:@"松开手指,取消发送"];
}

-(void)countVoiceTime
{
    self.recordTime += 0.5;
    if (self.recordTime >= 60) {
        [self.recorder stop];
    }
}

- (void)remindDragEnter:(UIButton *)button
{
    [UUProgressHUD changeSubTitle:@"向上滑动取消"];
}

#pragma AVAudioRecordDeleagte
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
 
    if (self.recordTime < 0.5) {
        [UUProgressHUD dismissWithError:@"时间太短"];
        [self.recordTimer invalidate];
        self.recordTimer = nil;
        return;
    }

    if (flag) {
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/arm.wav"];
        if (_observer && [_observer respondsToSelector:@selector(sendSound:)]) {
            [_observer sendSound:path];
        }
        
    }else{
        [UUProgressHUD dismissWithSuccess:@"录音失败"];
    }
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}


#pragma mark Public
- (void)setKeyboardHidden:(BOOL)hidden{
    if(hidden){
        [_contentTextView resignFirstResponder];
        _emojiBtn.selected = FALSE;
        _messageBtn.selected =FALSE;
        _moreItemBtn.selected = FALSE;
        [self movePostionWithY:self.currentScreenHeight - KINPUTVIEW_HEIGHT duration:0.25 curve:0.25];
    }else{
        [_contentTextView becomeFirstResponder];
    }
}




#pragma mark TextView_Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    //按下send 键
    if ([text isEqualToString:@"\n"]) {
 
        if ([_observer respondsToSelector:@selector(sendMessage:)]) {
            if (textView.text.length > 0) {
                
                [_observer sendMessage:textView.text];
            }
        }
        textView.text = nil;
        return NO;
    }
#pragma mark - 点击删除键 判断如果是表情 就删除表情字符
    if ([text length] != 0) {
    }else{
    }
    
    return YES;
}



- (void)sendFaceMessage
{
    if (_contentTextView.text.length > 0) {
        [_observer sendMessage:_contentTextView.text];
        
        
//        [self sendToHyphenate:_contentTextView.text];
        
        _contentTextView.text = nil;
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _emojiBtn.selected =  NO;
    _moreItemBtn.selected = NO;
    _contentTextView.hidden = FALSE;
    _talkBtn.hidden = TRUE;
    return YES;
}
#pragma mark 释放对象
- (void)dealloc{
    _observer = nil;

    
 
 
}


@end