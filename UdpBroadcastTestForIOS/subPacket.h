//
//  subPacket.h
//  UdpBroadcastTestForIOS
//
//  Created by CheerChen on 15-4-15.
//  Copyright (c) 2015年 sseOfUSTC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface subPacket : NSObject<NSCoding>
@property (nonatomic,copy) NSString *uuid;
@property (nonatomic) unsigned short seq;
@property (nonatomic,strong) NSData *subData;

-(id) initWithUUID:(NSString *) aUUID Seq:(unsigned short) theSeq subData:(NSData *) theSubData;
+(id) subPacketWithUUID:(NSString *)aUUID Seq:(unsigned short) theSeq subData:(NSData *) theSubData;

@end
