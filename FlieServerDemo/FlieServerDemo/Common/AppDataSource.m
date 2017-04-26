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
        self.currentUsers = [NSMutableArray array];
    }
    return self;
}



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
- (long long) freeDiskSpaceInBytes
{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
    
}


@end
