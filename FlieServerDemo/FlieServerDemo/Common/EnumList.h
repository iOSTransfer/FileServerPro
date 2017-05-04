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
    
    ResponsTypeNoLogin              = 0,     //未登录
    ResponsTypeServerError          = 1,     //服务器错误
    
    ResponsTypeRegisterSuccess      = 10,   //注册成功
    ResponsTypeRegisterNull         = 11,   //用户名密码不能为空
    ResponsTypeRegisterExist        = 12,   //注册用户名存在
    
    ResponsTypeLoginSuccess         = 20,   //登录成功
    ResponsTypeLoginError           = 21,   //用户名或密码错误
    ResponsTypeLoginExist           = 22,   //该账号在其他客户端登录
    
    ResponsTypeReqUpSuccess         = 30,   //允许上传
    ResponsTypeReqUpFull            = 31,   //服务器空间不足
    ResponsTypeReqUpNoFolder        = 32,   //文件夹不存在
    ResponsTypeReqUpFileExist       = 33,   //文件名已存在
    ResponsTypeReqUpFileNameNull    = 34,   //文件名不能为空
    
    ResponsTypeUping                = 40,   //上传中
    ResponsTypeUpSuccess            = 41,   //文件上传成功
    ResponsTypeUpFull               = 42,   //服务器空间不足
    ResponsTypeUpError              = 43,   //文件上传中断
    ResponsTypeUpFileExist          = 44,   //文件存在
    
    
    ResponsTypeReqDownSuccess       = 50,   //允许下载
    ResponsTypeReqDownNull          = 51,   //文件夹不存在或者文件不存在
    
    ResponsTypeDownIng              = 60,   //下载中
    ResponsTypeDownSuccess          = 61,   //文件下载完成
    ResponsTypeDownError            = 62,   //下载中断
    ResponsTypeDownNUll             = 63,   //文件不存在
    
    ResponsTypeAddFolderSuccess     = 70,   //文件夹创建成功
    ResponsTypeFolderExist          = 71,   //该文件夹存在
    ResponsTypeFolderParentNoExist  = 72,   //文件父目录不存在
    ResponsTypeFolderNameNull       = 73,   //文件名称不能为空
    
    ResponsTypeMoveFolderSuccess    = 80,   //文件夹删除
    ResponsTypeNoFolderOrNoParent   = 81,   //该文件夹或者父目录不存在

    ResponsTypeFileListSuccess      = 90,   //成功
    ResponsTypeFileListNoFolder     = 91,   //未找到该文件夹
    
    
};




#endif /* EnumList_h */
