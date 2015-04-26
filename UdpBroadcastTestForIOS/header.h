//
//  header.h
//  UdpBroadcastTestForIOS
//
//  Created by CheerChen on 15-4-24.
//  Copyright (c) 2015年 sseOfUSTC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface header : NSObject<NSCoding>
@property (nonatomic,copy) NSString *bottleUUID;
@property (nonatomic,copy) NSString *sourceIP;
@property unsigned int totalNum;

-(id) initWithBottleUUID:(NSString *) uuid sourceIP:(NSString *) theSourceIP totalNum:(unsigned int) theTotalNum;
+(id) headerWithBottleUUID:(NSString *) uuid sourceIP:(NSString *) theSourceIP totalNum:(unsigned int) theTotalNum;
@end
