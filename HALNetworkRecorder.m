//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALNetworkRecorder.h"
#import "HALServer.h"

@interface HALNetworkRecorder ()

@property (weak, nonatomic) HALServer *server;

@end

@implementation HALNetworkRecorder

#pragma mark Object cunstructors/destructors

- (id)initWithServer:(HALServer *)server
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.server = server;
    
    [self resetData];
    
    return self;
}

#pragma mark Virtual methods

- (void)resetData
{
    [super resetData];

    self.interfaces = [NSMutableArray array];

    if (self.delegate != nil)
        [self.delegate networkInterfacesReset];
}

- (void)serverDidConnect
{
    [super serverDidConnect];

    if (self.delegate != nil)
        [self.delegate networkInterfacesReset];
}

#pragma mark Parse input information

- (void)parseLine:(NSString *)line
{
    NSArray *parts = [line componentsSeparatedByString:@" "];
    if ([parts count] != 3)
        return;

    NSString *interfaceName = [parts objectAtIndex:0];
    
    long long rxBytes;
    long long txBytes;
    
    NSScanner *scanner;
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
    [scanner scanLongLong:&rxBytes];
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:2]];
    [scanner scanLongLong:&txBytes];
    
    BOOL found = NO;
    for (HALNetworkInterface *interface in self.interfaces)
    {
        if ([[interface interfaceName] compare:interfaceName] == NSOrderedSame)
        {
            [interface trafficRxBytes:rxBytes
                              txBytes:txBytes];

            if (self.delegate != nil)
                [self.delegate networkTrafficChanged:interface];

            found = YES;
            break;
        }
    }
    
    if (found == NO)
    {
        HALNetworkInterface *interface = [[HALNetworkInterface alloc] initWithInterfaceName:interfaceName
                                                                               rxBytesTotal:rxBytes
                                                                               txBytesTotal:txBytes];
        [self.interfaces addObject:interface];

        if (self.delegate != nil)
            [self.delegate networkInterfaceDetected:interface];
    }
}

@end
