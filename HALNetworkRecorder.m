//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALNetworkInterface.h"
#import "HALNetworkRecorder.h"
#import "HALServer.h"

@interface HALNetworkRecorder ()

@property (weak, nonatomic) HALServer *server;

@end

@implementation HALNetworkRecorder

- (id)initWithServer:(HALServer *)server
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.server = server;
    
    [self resetData];
    
    return self;
}

- (void)resetData
{
    [super resetData];

    self.interfaces = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkInterfacesReset"
                                                        object:self.server];
}

- (void)serverDidConnect
{
    [super serverDidConnect];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkInterfacesReset"
                                                        object:self.server];
}

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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkTrafficChanged"
                                                                object:interface];
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

        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkInterfaceDetected"
                                                            object:interface];
    }
}

@end
