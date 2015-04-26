//
//  subPacket.m
//  UdpBroadcastTestForIOS
//
//  Created by CheerChen on 15-4-15.
//  Copyright (c) 2015年 sseOfUSTC. All rights reserved.
//

#import "subPacket.h"

@implementation subPacket
@synthesize uuid, seq, subData;

-(id) initWithUUID:(NSString *) aUUID Seq:(unsigned short) theSeq subData:(NSData *) theSubData
{
    if(self =[super init])
    {
        self.uuid = aUUID;
        self.seq = theSeq;
        self.subData = theSubData;
    }
    return self;
}
+(id) subPacketWithUUID:(NSString *)aUUID Seq:(unsigned short) theSeq subData:(NSData *) theSubData;
{
    return [[subPacket alloc] initWithUUID:(NSString *)aUUID Seq:theSeq subData:theSubData];
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeInt32:self.seq forKey:@"seq"];
    [aCoder encodeObject:self.subData forKey:@"subData"];
    
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
        self.seq =[aDecoder decodeInt32ForKey:@"seq"];
        self.subData = [aDecoder decodeObjectForKey:@"subData"];
    }
    return self;
}
@end
