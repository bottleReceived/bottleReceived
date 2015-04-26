//
//  header.m
//  UdpBroadcastTestForIOS
//
//  Created by CheerChen on 15-4-24.
//  Copyright (c) 2015年 sseOfUSTC. All rights reserved.
//

#import "header.h"

@implementation header
@synthesize bottleUUID, sourceIP, totalNum;

-(id) initWithBottleUUID:(NSString *) uuid sourceIP:(NSString *) theSourceIP totalNum:(unsigned int) theTotalNum
{
    if(self = [super init])
    {
        self.bottleUUID = uuid;
        self.sourceIP = theSourceIP;
        self.totalNum = theTotalNum;
    }
    return self;
}
+(id) headerWithBottleUUID:(NSString *) uuid sourceIP:(NSString *) theSourceIP totalNum:(unsigned int) theTotalNum
{
    return [[header alloc] initWithBottleUUID:uuid sourceIP:theSourceIP totalNum:theTotalNum];
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bottleUUID forKey:@"theUUID"];
    [aCoder encodeObject:self.sourceIP forKey:@"theSourceIP"];
    [aCoder encodeInt:self.totalNum forKey:@"theTotalNum"];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.bottleUUID = [aDecoder decodeObjectForKey:@"theUUID"];
        self.sourceIP = [aDecoder decodeObjectForKey:@"theSourceIP"];
        self.totalNum = [aDecoder decodeIntForKey:@"theTotalNum"];
    }
    return self;
}
@end
