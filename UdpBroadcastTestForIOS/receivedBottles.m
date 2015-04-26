//
//  receivedBottles.m
//  UdpBroadcastTestForIOS
//
//  Created by CheerChen on 15-4-24.
//  Copyright (c) 2015年 sseOfUSTC. All rights reserved.
//

#import "receivedBottles.h"

@implementation receivedBottles
@synthesize bottleUUID, totalNum, subPackets;

-(id) initWithBottleUUID:(NSString *) theBottleUUID totalNum:(unsigned int) theTotalNum currentNum:(unsigned int) theCurrentNum
{
    if(self = [super init])
    {
        self.bottleUUID = theBottleUUID;
        self.totalNum = theTotalNum;
//        self.subPackets = [[NSMutableArray alloc] init];
    }
    
    return self;
}
+(id) receivedBottlesWithBottleUUID:(NSString *) theBottleUUID totalNum:(unsigned int) theTotalNum currentNum:(unsigned int) theCurrentNum
{
    return [[receivedBottles alloc] initWithBottleUUID:theBottleUUID totalNum:theTotalNum currentNum:(unsigned int) theCurrentNum];
}
@end
