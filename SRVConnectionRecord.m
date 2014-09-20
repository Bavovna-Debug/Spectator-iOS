//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SRVConnectionRecord.h"

@implementation SRVConnectionRecord

#pragma mark Object cunstructors/destructors

- (id)initWithIpAddress:(NSString *)ipAddress
             remotePort:(UInt16)remotePort
              localPort:(UInt16)localPort
{
    self = [super init];
    if (self == nil)
        return nil;

    self.openedStamp  = [NSDate date];
    self.closedStamp  = nil;

    self.ipAddress    = [NSString stringWithString:ipAddress];
    self.remotePort   = remotePort;
    self.localPort    = localPort;
    
    return self;
}

#pragma mark Class specific

- (id)closed
{
    SRVConnectionRecord *copy = [[SRVConnectionRecord alloc] init];

    copy.openedStamp  = self.openedStamp;
    copy.closedStamp  = [NSDate date];
    
    copy.ipAddress    = self.ipAddress;
    copy.remotePort   = self.remotePort;
    copy.localPort    = self.localPort;
    
    return copy;
}

@end
