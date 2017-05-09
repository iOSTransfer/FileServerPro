//
//  UpFileViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/5.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "UpFileViewController.h"
#import "FileStateCellModel.h"
#import "FileStateTableViewCell.h"
#import "socketClientManager.h"
#import "AppDataSource.h"
#import "ProtocolDataManager.h"

// 屏幕宽度、高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define COLOR(_r,_g,_b) [UIColor colorWithRed:_r / 255.0f green:_g / 255.0f blue:_b / 255.0f alpha:1]

@interface UpFileViewController ()<UITableViewDataSource,UITableViewDelegate,socketClientManagerDelegate,FileStateTableViewCellDelegate>{

    UITableView *upfilesTable;
}

@property (nonatomic , strong)NSArray *menuItems;
@property (nonatomic , strong)UIImageView *backImageView;
@property (nonatomic , strong)NSMutableArray *dataArray;
@property (nonatomic , strong)NSMutableArray *taskArray;

@end

@implementation UpFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"上传列表";
    self.view.backgroundColor = [UIColor whiteColor];
    self.taskArray = [NSMutableArray array];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"全部开始" style:UIBarButtonItemStyleDone target:self action:@selector(tapRightAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //创建设备tableView
    upfilesTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    upfilesTable.delegate = self;
    upfilesTable.dataSource =self;
    upfilesTable.showsVerticalScrollIndicator = NO;
    upfilesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINib *nib = [UINib nibWithNibName:@"FileStateTableViewCell" bundle:nil];
    [upfilesTable registerNib:nib forCellReuseIdentifier:@"fileUpCell"];
    [self.view addSubview:upfilesTable];
    
    //数据接收代理
    [socketClientManager sharedClientManager].delegate = self;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"内存要💥了啊");
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        
        //模拟数据
        FileStateCellModel *model = [FileStateCellModel new];
        model.fileName = [NSString stringWithFormat:@"图片%d.jpg",arc4random() % 100000];
        model.fileTypeImageName = @"ico_photos_small@3x";
        model.stateType = FileStateTypeStart;
        model.fileUpSize = 0;
        model.fileSize = [self getFileSizeWithName:@"BBB" andType:@"jpg"];
        model.filePath = [[NSBundle mainBundle] pathForResource:@"BBB" ofType:@"jpg"];
        [_dataArray addObject:model];
        
        FileStateCellModel *model0 = [FileStateCellModel new];
        model0.fileName = [NSString stringWithFormat:@"图片%d.jpg",arc4random() % 100000];
        model0.fileTypeImageName = @"ico_photos_small@3x";
        model0.stateType = FileStateTypeStart;
        model0.fileUpSize = 0;
        model0.fileSize = [self getFileSizeWithName:@"timg" andType:@"jpeg"];
        model0.filePath = [[NSBundle mainBundle] pathForResource:@"timg" ofType:@"jpeg"];
        [_dataArray addObject:model0];
        
        FileStateCellModel *model1 = [FileStateCellModel new];
        model1.fileName = [NSString stringWithFormat:@"视屏%d.mp4",arc4random() % 100000];
        model1.fileTypeImageName = @"ico_swf_small@3x";
        model1.stateType = FileStateTypeStart;
        model1.fileSize = [self getFileSizeWithName:@"NZQ" andType:@"mp4"];
        model1.fileUpSize = 0;
        model1.filePath = [[NSBundle mainBundle] pathForResource:@"NZQ" ofType:@"mp4"];
        [_dataArray addObject:model1];
        
        
        FileStateCellModel *model2 = [FileStateCellModel new];
        model2.fileName = [NSString stringWithFormat:@"归档%d.zip",arc4random() % 100000];
        model2.fileTypeImageName = @"ico_zip_small@3x";
        model2.stateType = FileStateTypeStart;
        model2.fileSize =  [self getFileSizeWithName:@"地中海" andType:@"zip"];
        model2.fileUpSize = 0;
        model2.filePath = [[NSBundle mainBundle] pathForResource:@"地中海" ofType:@"zip"];
        [_dataArray addObject:model2];
        
        
        
    }
    return _dataArray;
}

- (double)getFileSizeWithName:(NSString *)name andType:(NSString *)fileType;
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:fileType];
    NSData *filedata = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:nil];
    return (double)filedata.length / 1024;
}

- (void)tapRightAction
{
    [[upfilesTable visibleCells] enumerateObjectsUsingBlock:^(__kindof FileStateTableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self.taskArray addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager]reqUpFileDataWithFileName:obj.fileModel.fileName andDirectoryID:1 andSize:obj.fileModel.fileSize * 1024];
            [[socketClientManager sharedClientManager]sendData:data];
        });
    }];
    
    
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileStateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileUpCell"];
    cell.fileModel = _dataArray[indexPath.row];
    cell.delegate = self;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}


#pragma mark socketClientManagerDelegate
- (void)receiveReplyType:(ResponsType)replyType andKey:(u_short)key andCmd:(CmdType)cmd
{

    switch (cmd) {
        case CmdTypeReqUp:{

            if (replyType != ResponsTypeReqUpSuccess) {
                return;
            }
            
            if (self.taskArray.count < 1) {
                return;
            }
            NSIndexPath *path = self.taskArray[0];
            FileStateTableViewCell *cell = [upfilesTable cellForRowAtIndexPath:path];
            [self.taskArray removeObject:path];
            
            
            
//            NSData *filedata = [NSData dataWithContentsOfFile:cell.fileModel.filePath options:NSDataReadingUncached error:nil];
            u_short chunkSize = 1024;
            NSUInteger chunks = cell.fileModel.fileSize * 1024 / chunkSize + 1;
            while (chunks > 25000) {
                chunkSize += 1024;
                chunks = cell.fileModel.fileSize * 1024  / chunkSize + 1;
            }
            __weak NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:cell.fileModel.filePath];
            cell.fileModel.totalChunk = chunks;
            cell.fileModel.chunkSize = chunkSize;
            cell.fileModel.fileId = key;
            cell.fileModel.fileUpSize = chunkSize;
            cell.subProgress = 1.0 / (CGFloat)chunks;
            __block u_short currentChunk = 1;
            
            dispatch_async(dispatch_queue_create("sendFileData", DISPATCH_QUEUE_SERIAL), ^{
               __strong NSFileHandle *fileHandleStrong = [fileHandle mutableCopy];
                NSData *data;
                while (YES) {
                    [fileHandleStrong seekToFileOffset:(currentChunk - 1 )* chunkSize];
                    data = [fileHandle readDataOfLength:chunkSize];
                    NSData *chunkData = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:[AppDataSource shareAppDataSource].userToken andFileID:key andChunks:chunks andCurrentChunk:currentChunk andDataSize:data.length andSubFileData:data];
                    [[socketClientManager sharedClientManager] sendData:[chunkData copy]];
                    
                    chunkData = nil;
                    if (!data||[data length] < chunkSize) {
                        break;
                    }
                    currentChunk++;
                }
                
                [fileHandle closeFile];
                
                
//                NSMutableData *muData = [NSMutableData data];
//                for (u_short currentChunk = 1; currentChunk <= chunks; currentChunk++) {
//                    
//                    if (currentChunk == chunks) {
//                        u_short size = filedata.length % chunkSize;
//                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + chunkSize * (currentChunk - 1), size)];
//                        
//                        NSData *chunkData = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:[AppDataSource shareAppDataSource].userToken andFileID:key andChunks:chunks andCurrentChunk:currentChunk andDataSize:size andSubFileData:subData];
////                        [muData appendData:chunkData];
//                        [[socketClientManager sharedClientManager] sendData:chunkData];
//                        chunkData = nil;
//                        subData = nil;
//                    }else{
//                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + chunkSize * (currentChunk - 1), chunkSize)];
//                        NSData *chunkData = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:[AppDataSource shareAppDataSource].userToken andFileID:key andChunks:chunks andCurrentChunk:currentChunk andDataSize:chunkSize andSubFileData:subData];
////                        [muData appendData:chunkData];
//                        [[socketClientManager sharedClientManager] sendData:chunkData];
//                        chunkData = nil;
//                        subData = nil;
//                    }
//                }
//                filedata = nil;
            });
            
        }
            
            break;
        case CmdTypeUp:{
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[upfilesTable visibleCells] enumerateObjectsUsingBlock:^(__kindof FileStateTableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.fileModel.fileId == key) {
                        if (replyType == ResponsTypeUpSuccess) {
                            [obj.fileStateButton setTintColor:[UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1]];
                            [obj.fileStateButton setImage:[[UIImage imageNamed:@"fileOk"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                            [obj.progressLayer removeFromSuperlayer];
                            obj.fileProgress.text = [NSString stringWithFormat:@"%.2fkb/%.2fkb",obj.fileModel.fileSize,obj.fileModel.fileSize];
                            
                        }else if (replyType == ResponsTypeUping){
                            obj.subProgressCount ++;
                            obj.progressLayer.strokeEnd = obj.subProgressCount * obj.subProgress;
                            obj.fileProgress.text = [NSString stringWithFormat:@"%.2dkb/%.2fkb",obj.fileModel.chunkSize / 1024 * obj.subProgressCount,obj.fileModel.fileSize];
                            
                        }
                        *stop = YES;
                    }
                }];
                
                
            });
            
            
            
        }
            
            break;
            
        default:
            break;
    }
    

}

#pragma mark FileStateTableViewCellDelegate
- (void)tapUpfileButton:(FileStateTableViewCell *)cell
{
    NSIndexPath *indexPath = [upfilesTable indexPathForCell:cell];
    [self.taskArray addObject:indexPath];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [[ProtocolDataManager sharedProtocolDataManager]reqUpFileDataWithFileName:cell.fileModel.fileName andDirectoryID:1 andSize:cell.fileModel.fileSize * 1024];
        [[socketClientManager sharedClientManager]sendData:data];
    });
    
    

}

@end
