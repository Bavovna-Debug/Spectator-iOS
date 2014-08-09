//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALConnectionRecord.h"

@implementation HALConnectionRecord

- (id)initWithServer:(HALServer *)server
                host:(NSString *)ipAddress
          remotePort:(UInt16)remotePort
           localPort:(UInt16)localPort
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.server = server;

    self.openedStamp = [NSDate date];
    self.closedStamp = nil;

    self.ipAddress = [NSString stringWithString:ipAddress];
    self.remotePort = remotePort;
    self.localPort = localPort;
    
    return self;
}

- (id)closed
{
    HALConnectionRecord *copy = [[HALConnectionRecord alloc] init];

    copy.openedStamp = self.openedStamp;
    copy.closedStamp = [NSDate date];
    
    copy.ipAddress = self.ipAddress;
    copy.remotePort = self.remotePort;
    copy.localPort = self.localPort;
    
    return copy;
}

@end
