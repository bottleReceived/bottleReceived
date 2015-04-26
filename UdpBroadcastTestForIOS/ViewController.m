//
//  ViewController.m
//  UdpBroadcastTestForIOS
//
//  Created by CheerChen on 15-3-7.
//  Copyright (c) 2015年 sseOfUSTC. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "subPacket.h"
#import "IPAddress.h"
#import "receivedBottles.h"
#import "header.h"


#define SUB_PACKET_LENGTH 1144
#define NUMBER_OF_RECEIVED_BOTTLES 7
@interface ViewController ()
{
    GCDAsyncUdpSocket *_gcdUdpSocket;
    NSString *_deviceIP;
    NSString *_receivedFilePath;
    NSMutableData *_tempFileData;
    NSMutableArray *_receivedFileName;
    int _testNum;

}
@property (weak, nonatomic) IBOutlet UILabel *txtReceived;
@property (weak, nonatomic) IBOutlet UITextField *txtSend;
@property (weak, nonatomic) IBOutlet UIImageView *imgReceived;


@end

@implementation ViewController
@synthesize _receivedBottles;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *err=nil;
    _testNum = 0;
  
    
    _gcdUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_gcdUdpSocket enableBroadcast:YES error:&err];
    [_gcdUdpSocket bindToPort:9527 error:&err];
    if(![_gcdUdpSocket beginReceiving:&err])
    {
        NSLog(@"Error receiving:%@",err);
        return;
    }
    _deviceIP = [self deviceIPAddress];
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _receivedFilePath = [doc stringByAppendingPathComponent:@"receivedFiles.plist"];
    _receivedFileName = [NSMutableArray arrayWithContentsOfFile:_receivedFilePath];
    if(_receivedFileName == nil)
        _receivedFileName  = [[NSMutableArray alloc] init];
    
    //初始化_receivedBottles
    _receivedBottles = [[NSMutableArray alloc] init];
    for(int i =0;i<NUMBER_OF_RECEIVED_BOTTLES;i++)
    {
        [_receivedBottles addObject:[receivedBottles receivedBottlesWithBottleUUID:nil totalNum:0 currentNum:0]];
    }

    //
    _tempFileData = [[NSMutableData alloc] init];
}
-(NSString *) deviceIPAddress
{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    //ip_names[0]:127.0.0.1; ip_names[1]:localIP
    return 	[NSString stringWithFormat:@"%s",ip_names[1]];
    
}

-(NSArray *) splitPacket:(NSData *)dataPacket withUUID:(NSString *) pUUID
{
    if(dataPacket ==nil)
        return nil;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    unsigned long chunks = dataPacket.length / SUB_PACKET_LENGTH;//当文件过大，怎么处理。当文件小于SUB_PACKET_LENGTH，同样可以。
    int reminder = dataPacket.length % SUB_PACKET_LENGTH;
    
    for(unsigned short i = 0;i< chunks;i++)
    {
        
        subPacket *aSubPacket =[subPacket subPacketWithUUID:(NSString *) pUUID Seq:i subData:[dataPacket subdataWithRange: NSMakeRange(i*SUB_PACKET_LENGTH, SUB_PACKET_LENGTH)]];
        NSData *subData = [NSKeyedArchiver archivedDataWithRootObject:aSubPacket];
        [result addObject:subData];
    }
    if(reminder > 0)
    {
        subPacket *aSubPacket =[subPacket subPacketWithUUID:(NSString *) pUUID Seq:(unsigned short)chunks subData:[dataPacket subdataWithRange: NSMakeRange(chunks*SUB_PACKET_LENGTH, reminder)]];
        NSData *subData = [NSKeyedArchiver archivedDataWithRootObject:aSubPacket];
        [result addObject:subData];
    }
    
    return result;
}

- (IBAction)broadcastImg:(UIButton *)sender {
    NSString *fileName = [NSString stringWithFormat: @"/Users/cheerchen/Desktop/%@.jpg",self.txtSend.text ];
    NSData * img = [NSData dataWithContentsOfFile:fileName];
    NSString *pUUID = [NSUUID UUID].UUIDString;
    NSArray *subPackets = [self splitPacket:img withUUID:pUUID];
    header *bottleHeader = [[header alloc] initWithBottleUUID:pUUID sourceIP:[self deviceIPAddress] totalNum:(unsigned int)subPackets.count];
    //先广播报头
    [_gcdUdpSocket sendData:[NSKeyedArchiver archivedDataWithRootObject:bottleHeader] toHost:@"255.255.255.255" port:9527 withTimeout:-1 tag:1];
    //再逐个广播数据包
    for(int i = 0;i<subPackets.count;i++)
    {
        [_gcdUdpSocket sendData:[subPackets objectAtIndex:i] toHost:@"255.255.255.255" port:9527 withTimeout:-1 tag:1];
        NSLog(@"%d",i);
    }
    
}
- (IBAction)broadcastMsg:(UIButton *)sender {
    NSData * broadMsg = [self.txtSend.text dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdUdpSocket sendData:broadMsg toHost:@"255.255.255.255" port:9527 withTimeout:-1 tag:0];
    
//    [_udpSocket sendData:broadMsg toHost:@"255.255.255.255" port:9527 withTimeout:-1 tag:0];

    
}
#pragma mark ------协议方法----
//没有发送出消息

-(void) udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"not send: %@",[error localizedDescription]);
}


-(BOOL) udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    _testNum++;
    NSLog(@"testNum:%d",_testNum);
    id receivedPacket = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if([receivedPacket isKindOfClass:[header class]])
    {
        header *tempHeader = (header *)receivedPacket;
        //判断是否接收过此文件
        
        if ([_receivedFileName containsObject:tempHeader.bottleUUID]) {
            return YES;
        }
        
        [_receivedFileName addObject: tempHeader.bottleUUID];
        [_receivedFileName writeToFile:_receivedFilePath atomically:YES];
        
        for(int i =0;i<_receivedBottles.count;i++)
        {
            receivedBottles *tempBottle =(receivedBottles *)_receivedBottles[i];
            //如果这个瓶子还没有存放数据，就使用这个瓶子
            if(tempBottle.subPackets == nil)
            {
                tempBottle.bottleUUID = tempHeader.bottleUUID;
                tempBottle.totalNum = tempHeader.totalNum;
                tempBottle.currentNum = 0;
                tempBottle.subPackets = [[NSMutableArray alloc] initWithCapacity:tempHeader.totalNum];
                // 初始化子包数组
                for(int j = 0;j<tempHeader.totalNum;j++)
                {
                    tempBottle.subPackets[j] = [[NSData alloc] init];
                }
                break;
            }
        }
        
    }
    else
    {
        subPacket *aSubPacket =(subPacket *)receivedPacket;
        for (int i = 0; i<_receivedBottles.count; i++) {
            //当_receivedBottles[i]是aSubPacket的header创建的瓶子，并且_receivedBottles[i]的subPackets[aSubPacket.seq]还没有附值（当已经附值了，证明是过来当重复的包，就不用附值了）
            receivedBottles *tempBottle = (receivedBottles *)_receivedBottles[i];
            if( [aSubPacket.uuid isEqualToString:tempBottle.bottleUUID] &&((NSData *)(tempBottle.subPackets[aSubPacket.seq])).length == 0 )
            {
                tempBottle.subPackets[aSubPacket.seq] = aSubPacket.subData;
                tempBottle.currentNum++;
                NSLog(@"currentNum:%d",tempBottle.currentNum);
                //当接收完成之后，就写入到文件，然后释放数组。
                if(tempBottle.currentNum == tempBottle.totalNum)
                {
                    NSMutableData *fileData = [[NSMutableData alloc] init];
                    for(int j = 0;j<tempBottle.subPackets.count;j++)
                    {
                        [fileData appendData:tempBottle.subPackets[j]];
                    }
                    
                    NSMutableString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", aSubPacket.uuid ]];
                    
                    [fileData writeToFile:path atomically:YES];
                    tempBottle.subPackets = nil;
                    tempBottle.currentNum = 0;
                    self.imgReceived.image = [UIImage imageWithData:fileData];
                }
            }
        }
        
    }
    
    return YES;
}

-(void)onUdpSocket:(GCDAsyncUdpSocket *)sock didNotReceiveDataWithTag: (long)tag dueToError:(NSError *)error{
    NSLog(@"数据未接收到。errorCode:%ld , error:%@",(long)[error code],[error localizedDescription]);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
//    NSLog(@"already send,tag:%ld",tag);
}
//断开连接

-(void) udpSocket:(GCDAsyncUdpSocket *) sock didNotConnect:(NSError *)error
{
    NSLog(@"lost connection:%@",[error localizedDescription]);
}

@end
