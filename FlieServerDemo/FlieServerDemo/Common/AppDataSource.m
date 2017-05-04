//
//  AppDataSource.m
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/4/23.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "AppDataSource.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <sys/param.h>
#include <sys/mount.h>

static AppDataSource *_dataStone;

@implementation AppDataSource

+ (instancetype)shareAppDataSource
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _dataStone = [[self alloc]init];
        
    });
    return _dataStone;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.currentUsers = [NSMutableSet set];
    }
    return self;
}


#pragma mark 服务端使用

- (NSString *)deviceIPAdress {
    NSString *address = @"获取ip发生错误";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

//手机剩余空间
- (double) freeDiskSpaceInBytes
{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
    
}

#pragma mark 客户端使用

//响应码转详细信息
- (NSString *)getStringWithRte:(ResponsType)type
{
    switch (type) {
        case ResponsTypeNoLogin:
            return @"未登录";
            break;
        case ResponsTypeServerError:
            return @"服务器错误";
            break;
            
            
        case ResponsTypeRegisterSuccess:
            return @"注册成功";
            break;
        case ResponsTypeRegisterNull:
            return @"用户名密码不能为空";
            break;
        case ResponsTypeRegisterExist:
            return @"注册用户名存在";
            break;
            
            
        case ResponsTypeLoginSuccess:
            return @"登录成功";
            break;
        case ResponsTypeLoginError:
            return @"用户名或者密码错误";
            break;
        case ResponsTypeLoginExist:
            return @"该用户在其他客户端登录";
            break;
            
            
        case ResponsTypeReqUpSuccess:
            return @"允许上传";
            break;
        case ResponsTypeReqUpFull:
            return @"服务器空间不足";
            break;
        case ResponsTypeReqUpNoFolder:
            return @"文件夹不存在";
            break;
        case ResponsTypeReqUpFileExist:
            return @"文件名已存在";
            break;
        case ResponsTypeReqUpFileNameNull:
            return @"文件名不能为空";
            break;
            
            
        case ResponsTypeUping:
            return @"上传中";
            break;
        case ResponsTypeUpSuccess:
            return @"文件上传成功";
            break;
        case ResponsTypeUpFull:
            return @"服务器空间不足";
            break;
        case ResponsTypeUpError:
            return @"文件上传中断";
            break;
            
            
        case ResponsTypeReqDownSuccess:
            return @"允许下载";
            break;
        case ResponsTypeReqDownNull:
            return @"文件夹不存在或者文件不存在";
            break;
            
            
        case ResponsTypeDownIng:
            return @"下载中";
            break;
        case ResponsTypeDownSuccess:
            return @"文件下载完成";
            break;
        case ResponsTypeDownError:
            return @"下载中断";
            break;
        case ResponsTypeDownNUll:
            return @"文件不存在";
            break;
            
            
            
        case ResponsTypeAddFolderSuccess:
            return @"文件夹创建成功";
            break;
        case ResponsTypeFolderExist:
            return @"该文件夹存在";
            break;
        case ResponsTypeFolderParentNoExist:
            return @"文件父目录不存在";
            break;
        case ResponsTypeFolderNameNull:
            return @"文件名称不能为空";
            break;
            
            
            
        case ResponsTypeMoveFolderSuccess:
            return @"文件夹删除成功";
            break;
        case ResponsTypeNoFolderOrNoParent:
            return @"该文件夹或者父目录不存在";
            break;
            
            
            
        case ResponsTypeFileListSuccess:
            return @"请求成功";
            break;
        case ResponsTypeFileListNoFolder:
            return @"未找到该文件夹";
            break;
            
        default:
            return @"错误代码";
            break;
    }
}


@end
