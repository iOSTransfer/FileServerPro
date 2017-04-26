//
//  ProtocolDataManager.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/25.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "ProtocolDataManager.h"

static ProtocolDataManager *_dataManager;



@implementation ProtocolDataManager

+ (instancetype)sharedProtocolDataManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _dataManager = [[self alloc]init];
        
    });
    return _dataManager;

}

#pragma mark  请求部分拼装

//给真实数据添加协议头信息
- (NSData *)protocolDataWithCmd:(Byte)cmd andData:(NSData *)data
{
    Byte cmdByte = cmd;
    Byte ver = 1;
    Byte pad = 0;
    
    uint c_length = (uint)data.length;
    
    
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&cmdByte length:sizeof(Byte)];
    [muData appendBytes:&ver length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&c_length length:sizeof(uint)];
    [muData appendData:data];
    
    return [muData copy];
}

//注册信息组装
- (NSData *)regDataWithUserName:(NSString *)userName andPassword:(NSString *)pwd
{
    
    NSData *userNameData = [userName dataUsingEncoding:NSUTF8StringEncoding];
    NSData *pwdData = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    
    Byte userNameLength = (Byte)userNameData.length;
    Byte pwdLength = (Byte)pwdData.length;
    Byte pad = 0;
    
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&userNameLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendData:userNameData];
    
    [muData appendBytes:&pwdLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    [muData appendData:pwdData];
    
     return [self protocolDataWithCmd:1 andData:muData];
    
}

//登录信息组装
- (NSData *)loginDataWithUserName:(NSString *)userName andPassword:(NSString *)pwd
{

    NSData *userNameData = [userName dataUsingEncoding:NSUTF8StringEncoding];
    NSData *pwdData = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    
    Byte userNameLength = (Byte)userNameData.length;
    Byte pwdLength = (Byte)pwdData.length;
    Byte pad = 0;
    
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&userNameLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendData:userNameData];
    
    [muData appendBytes:&pwdLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    [muData appendData:pwdData];
    
    return [self protocolDataWithCmd:2 andData:muData];

}


#pragma mark  响应数据拼装

//给真实数据添加响应头信息
- (NSData *)resHeaderDataWithCmd:(Byte)cmd andResult:(Byte)result andData:(NSData *)data
{
    Byte ver = 1;
    Byte pad = 0;
    uint r_length = (uint)data.length;
    
    
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&cmd length:sizeof(Byte)];
    [muData appendBytes:&result length:sizeof(Byte)];
    [muData appendBytes:&ver length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&r_length length:sizeof(uint)];
    [muData appendData:data];

    return [muData copy];

}

//注册响应信息组装
- (NSData *)resRegisterDataWithRet:(ResponsType)type
{
    Byte pad = 0;
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    return [muData copy];
}

//登录响应信息组装
- (NSData *)resLoginDataWithRet:(ResponsType)type andUserToken:(u_short)token
{
    Byte pad = 0;
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&token length:sizeof(u_short)];
    
    return [muData copy];



}



#pragma mark  响应部分解析

//解析用户名&密码信息
- (HeaderInfo *)getHeaderInfoWithData:(NSData *)data
{
    Byte cmdByte;
    Byte ver;
    
    uint c_length;

    [[data subdataWithRange:NSMakeRange(0, 1)] getBytes:&cmdByte length:sizeof(Byte)];
    [[data subdataWithRange:NSMakeRange(1, 1)] getBytes:&ver length:sizeof(Byte)];
    [[data subdataWithRange:NSMakeRange(4, 4)] getBytes:&c_length length:sizeof(uint)];
    
    HeaderInfo *header = [HeaderInfo new];
    header.cmd = cmdByte;
    header.ver = ver;
    header.c_length = c_length;
    
    return header;
}

//解析用户名&密码信息
- (UserInfo *)getUserInfoWithData:(NSData *)data
{
    
    UserInfo *user = [[UserInfo alloc]init];
    
    Byte userNameLength;
    [[data subdataWithRange:NSMakeRange(0, 1)] getBytes:&userNameLength length:sizeof(Byte)];
    
    user.userName  =[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, userNameLength)]  encoding:NSUTF8StringEncoding];
    
    
    Byte pwdLength;
    [[data subdataWithRange:NSMakeRange(4 + userNameLength, 1)] getBytes:&pwdLength length:sizeof(Byte)];
    
    user.userPwd = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange( userNameLength + 4 + 4, pwdLength)]  encoding:NSUTF8StringEncoding];
    

    return user;
}
















@end
