//
//  LoginViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/4.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "LoginViewController.h"
#import "BorderTextField.h"
#import "UIView+Add.h"
#import "socketClientManager.h"
#import "MBProgressHUD+Add.h"
#import "AppDataSource.h"
#import "ClientMainViewController.h"
// 屏幕宽度、高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define COLOR(_r,_g,_b) [UIColor colorWithRed:_r / 255.0f green:_g / 255.0f blue:_b / 255.0f alpha:1]


@interface LoginViewController ()<socketClientManagerDelegate>

@property(nonatomic , strong)BorderTextField *userNameTextField;
@property(nonatomic , strong)BorderTextField *passwordTextField;
@property(nonatomic , strong)UIButton *okButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"客户端";
    self.view.backgroundColor = [UIColor whiteColor];
    //账号
    self.userNameTextField = [[BorderTextField alloc]initWithFrame:CGRectMake(0 , 94, SCREEN_WIDTH * 0.8 , 50)];
    UIColor *attrsColor = COLOR(45, 191, 244);
    NSDictionary *attrs = @{NSForegroundColorAttributeName : attrsColor};
    NSAttributedString *tip = [[NSAttributedString alloc]initWithString:@"请输入账号"  attributes:attrs];
    self.userNameTextField.attributedPlaceholder = tip;
    self.userNameTextField.centerX = SCREEN_WIDTH /2;
    [self.view addSubview:self.userNameTextField];
    
    
    //密码
    self.passwordTextField = [[BorderTextField alloc]initWithFrame:CGRectMake(0, self.userNameTextField.y + 50 + 15, SCREEN_WIDTH * 0.8, 50)];
    [self.passwordTextField setKeyboardType:UIKeyboardTypeASCIICapable];
    NSAttributedString *passwordTip = [[NSAttributedString alloc]initWithString:@"请输入密码"  attributes:attrs];
    self.passwordTextField.attributedPlaceholder = passwordTip;
    self.passwordTextField.centerX = SCREEN_WIDTH /2;
    self.passwordTextField.secureTextEntry = YES;
    [self.view addSubview:self.passwordTextField];
    
    
    //登录
    self.okButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_passwordTextField.frame) +44, SCREEN_WIDTH * 0.8, 50)];
    self.okButton.centerX = self.view.centerX;
    self.okButton.backgroundColor = [UIColor lightGrayColor];
    [self.okButton setTitle:@"登录" forState:UIControlStateNormal];
    self.okButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.okButton addTarget:self action:@selector(tapOkButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.okButton];
    
    //添加textField监听
    [self.userNameTextField addTarget:self action:@selector(CheckTextFieldInput:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(CheckTextFieldInput:) forControlEvents:UIControlEventEditingChanged];
    
    self.userNameTextField.text = @"aaaa";
    self.passwordTextField.text = @"111111";
}

//监听textField是否有输入
-(void)CheckTextFieldInput:(UITextField *)textField{
    
    if (_userNameTextField.text.length > 0 &&  _passwordTextField.text.length > 0 ) {
        self.okButton.enabled = YES;
        self.okButton.backgroundColor = [UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1];
    }else{
        self.okButton.enabled = NO;
        self.okButton.backgroundColor = [UIColor lightGrayColor];
    }
    
}

//取消输入
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)tapOkButton
{
    [self.view endEditing:YES];
    
    if ([[socketClientManager sharedClientManager] connectServer]) {
        UserInfo *user = [[UserInfo alloc]init];
        user.userName = _userNameTextField.text;
        user.userPwd = _passwordTextField.text;
        [socketClientManager sharedClientManager].delegate = self;
        [[socketClientManager sharedClientManager] sendLoginInfo:user];
    }else{
        [MBProgressHUD showTextTip:@"连接服务器失败"];
    }


}

#pragma mark 
- (void)receiveReplyType:(ResponsType)replyType andKey:(u_short)key andCmd:(CmdType)cmd
{
    if (cmd != CmdTypeLogin) {
        return;
    }
    if (replyType != ResponsTypeLoginSuccess) {
        [MBProgressHUD showTextTip:[[AppDataSource shareAppDataSource] getStringWithRte:replyType]];
        return;
    }
    [AppDataSource shareAppDataSource].userToken = key;

    [self.navigationController pushViewController:[ClientMainViewController new] animated:YES];

    
}


@end
