//
//  EnumList.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/26.
//  Copyright © 2017年 lyric. All rights reserved.
//

#ifndef EnumList_h
#define EnumList_h



typedef NS_ENUM(Byte, CmdType) {
    CmdTypeReigter      = 1,        //注册命令
    CmdTypeLogin        = 2,        //登录命令
    CmdTypeReqUp        = 3,        //请求上传命令
    CmdTypeUp           = 4,        //上传命令
    CmdTypeReqDown      = 5,        //请求下载命令
    CmdTypeDown         = 6,        //下载命令
    CmdTypeAddFolder    = 7,        //添加文件夹
    CmdTypeRemoveFolder = 8,        //删除文件夹
    CmdTypeGetList      = 9,        //浏览资源
    
};

typedef NS_ENUM(Byte, ResultType) {
    ResultTypeSuccess       = 0,        //正常返回
    ResultTypeBusy          = 1,        //服务器繁忙
    ResultTypeNoCmd         = 2,        //无法识别的命令
    ResultTypeDataError     = 3,        //真实数据格式不对解析失败

    
};


typedef NS_ENUM(Byte, ResponsType) {
    ResponsTypeRegisterSuccess = 10, //注册成功
    ResponsTypeRegisterNull = 11,    //用户名密码不能为空
    ResponsTypeRegisterExist = 12,   //注册用户名存在
    
    
    ResponsTypeLoginSuccess = 20, //登录成功
    ResponsTypeLoginError = 21,    //用户名或密码错误
    ResponsTypeLoginExist = 22,   //该账号在其他客户端登录
};







#endif /* EnumList_h */
