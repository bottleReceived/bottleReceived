//
//  receivedBottles.h
//  UdpBroadcastTestForIOS
//
//  Created by CheerChen on 15-4-24.
//  Copyright (c) 2015年 sseOfUSTC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface receivedBottles : NSObject
@property (nonatomic,copy) NSString *bottleUUID;
@property unsigned int totalNum;
@property unsigned int currentNum;
@property (nonatomic,strong) NSMutableArray *subPackets;

-(id) initWithBottleUUID:(NSString *) theBottleUUID totalNum:(unsigned int) theTotalNum currentNum:(unsigned int) theCurrentNum;
+(id) receivedBottlesWithBottleUUID:(NSString *) theBottleUUID totalNum:(unsigned int) theTotalNum currentNum:(unsigned int) theCurrentNum;
@end
