//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALConnectionsRecorder.h"
#import "HALConnectionRecord.h"
#import "HALServer.h"

@interface HALConnectionsRecorder ()

@property (weak, nonatomic) HALServer *server;

@end

@implementation HALConnectionsRecorder

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

    self.activeConnections = [NSMutableArray array];
    self.closedConnections = [NSMutableArray array];
}

- (void)serverDidConnect
{
    [super serverDidConnect];

    [self.closedConnections addObjectsFromArray:self.activeConnections];
    [self.activeConnections removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ActiveConnectionsCleared"
                                                        object:self.server];
}

- (void)parseLine:(NSString *)line
{
    NSArray *parts;
    
    parts = [line componentsSeparatedByString:@" "];
    NSString *prefix = [parts objectAtIndex:0];
    NSString *localPortString = [parts objectAtIndex:1];
    NSString *remoteHostInfo = [parts objectAtIndex:2];

    UniChar operationCode = [prefix characterAtIndex:0];
    UniChar ipVersion = [prefix characterAtIndex:1];
    
    NSString *remoteIpAddress;
    NSString *remotePortString;
    
    if (ipVersion == '0') {
        parts = [remoteHostInfo componentsSeparatedByString:@":"];
        remoteIpAddress = [parts objectAtIndex:0];
        remotePortString = [parts objectAtIndex:1];
    } else if (ipVersion == '6') {
        parts = [[remoteHostInfo substringFromIndex:1] componentsSeparatedByString:@"]:"];
        remoteIpAddress = [parts objectAtIndex:0];
        remotePortString = [parts objectAtIndex:1];
    } else {
        return;
    }

    unsigned int remotePortNumber;
    unsigned int localPortNumber;
    
    NSScanner *scanner;
    
    scanner = [NSScanner scannerWithString:remotePortString];
    [scanner scanHexInt:&remotePortNumber];

    scanner = [NSScanner scannerWithString:localPortString];
    [scanner scanHexInt:&localPortNumber];

    if (operationCode == '+') {
        HALConnectionRecord *activeConnection = [[HALConnectionRecord alloc] initWithServer:self.server
                                                                                               host:remoteIpAddress
                                                                                         remotePort:remotePortNumber
                                                                                          localPort:localPortNumber];
        //[activeConnection setRecordId:recordId++];
        [self.activeConnections addObject:activeConnection];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ActiveConnectionAppeared"
                                                            object:activeConnection];
    } else if (operationCode == '-') {
        for (HALConnectionRecord *activeConnection in self.activeConnections)
        {
            if ((activeConnection.localPort == localPortNumber) &&
                (activeConnection.remotePort == remotePortNumber) &&
                ([activeConnection.ipAddress compare:remoteIpAddress] == NSOrderedSame))
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ActiveConnectionDisappeared"
                                                                    object:activeConnection];
                
                HALConnectionRecord *closedConnection = [activeConnection closed];

                [self.activeConnections removeObject:activeConnection];

                //[closedConnection setRecordId:recordId++];
                
                [self.closedConnections addObject:closedConnection];
                
                break;
            }
        }
    }
}

@end
