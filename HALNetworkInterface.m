//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALNetworkInterface.h"

@implementation HALNetworkInterface

@synthesize gaging = _gaging;

- (id)initWithInterfaceName:(NSString *)interfaceName
               rxBytesTotal:(UInt64)rxBytesTotal
               txBytesTotal:(UInt64)txBytesTotal
{
    self = [super init];
    if (self == nil)
        return nil;

    self.interfaceName = interfaceName;
    self.rxBytesTotal = rxBytesTotal;
    self.txBytesTotal = txBytesTotal;
    
    [self setGaging:YES];
    
    return self;
}

- (void)trafficRxBytes:(UInt64)rxBytes
               txBytes:(UInt64)txBytes
{
    if (self.gaging) {
        self.rxBytesGaging += rxBytes - self.rxBytesTotal;
        self.txBytesGaging += txBytes - self.txBytesTotal;
    }

    self.rxBytesTotal = rxBytes;
    self.txBytesTotal = txBytes;
}

- (Boolean)gaging
{
    return _gaging;
}

- (void)setGaging:(Boolean)gaging
{
    if ((_gaging == NO) && (gaging == YES)) {
        self.gagingBegin = [NSDate date];
        self.rxBytesGaging = 0;
        self.txBytesGaging = 0;
        self.gagingEnd = nil;
    } else if ((_gaging == YES) && (gaging == NO)) {
        self.gagingEnd = [NSDate date];
    }

    _gaging = gaging;
}

@end
