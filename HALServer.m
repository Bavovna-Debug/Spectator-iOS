//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALServer.h"
#import "HALServerPool.h"

typedef enum {
    HALNotReceiving,
    
    HALIntroductionCPUSetup,
    HALIntroductionHostname,
    HALIntroductionIOTimeout,
    HALIntroductionMemory,
    HALIntroductionNetSetup,
    HALIntroductionReconnectTimeout,
    HALIntroductionSensors,
    HALIntroductionSwap,
    HALIntroductionSystemName,
    HALIntroductionUptime,
    HALIntroductionVersion,
    
    HALReceivingCPU,
    HALReceivingDisk,
    HALReceivingInet,
    HALReceivingMemory,
    HALReceivingMounts,
    HALReceivingNet,
    HALReceivingProc,
    HALReceivingSensors,
    HALReceivingSwap,
    HALReceivingUptime
} HALReceivingDataType;

@interface HALServer ()

@property (strong, nonatomic) NSTimer *cpuRangeTimer;

@end

@implementation HALServer
{
    GCDAsyncSocket *socket;
    Boolean forcedDisconnect;
    Boolean handshaking;
    HALReceivingDataType receivingDataType;
}

@synthesize serverName = _serverName;
@synthesize dnsName = _dnsName;
@synthesize portNumber = _portNumber;

#pragma mark Object cunstructors/destructors

- (id)initWithName:(NSString *)serverName
           dnsName:(NSString *)dnsName
{
    self = [super init];
    if (self == nil)
        return nil;

    self.serverName = serverName;
    self.dnsName = dnsName;
    self.portNumber = 19150;
    self.reconnectImmediately = YES;
    self.connectionTimeout = 5.0f;
    
    self.cpuRangeTimer = nil;
    
    socket = nil;
    forcedDisconnect = NO;
    handshaking = NO;
    receivingDataType = HALNotReceiving;

    self.serverToldVersion = nil;
    self.serverToldHostname = nil;
    self.serverToldSystemName = nil;
    self.serverToldIOTimeout = 0.0f;
    self.serverToldReconnectTimeout = 0.0f;
    self.serverUptime = 0;
    
    self.processorsRecorder = [[HALProcessorsRecorder alloc] initWithServer:self];
    self.memoryRecorder = [[HALMemoryRecorder alloc] initWithServer:self];
    self.swapRecorder = [[HALSwapRecorder alloc] initWithServer:self];
    self.mountsRecorder = [[HALMountsRecorder alloc] initWithServer:self];
    self.connections = [[HALConnectionsRecorder alloc] initWithServer:self];
    self.networkRecorder = [[HALNetworkRecorder alloc] initWithServer:self];
        
    self.associatedViewController = nil;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self == nil)
        return nil;

    self.serverName = [decoder decodeObjectForKey:@"ServerName"];
    self.dnsName = [decoder decodeObjectForKey:@"DnsName"];
    self.portNumber = [decoder decodeIntForKey:@"PortNumber"];
    self.reconnectImmediately = [decoder decodeBoolForKey:@"ReconnectImmediately"];

    self.connectionTimeout = 5.0f;
    
    self.cpuRangeTimer = nil;
    
    socket = nil;
    forcedDisconnect = NO;
    handshaking = NO;
    receivingDataType = HALNotReceiving;
    
    self.serverToldVersion = nil;
    self.serverToldHostname = nil;
    self.serverToldSystemName = nil;
    self.serverToldIOTimeout = 0.0f;
    self.serverToldReconnectTimeout = 0.0f;
    self.serverUptime = 0;
    
    self.processorsRecorder = [[HALProcessorsRecorder alloc] initWithServer:self];
    self.memoryRecorder = [[HALMemoryRecorder alloc] initWithServer:self];
    self.swapRecorder = [[HALSwapRecorder alloc] initWithServer:self];
    self.mountsRecorder = [[HALMountsRecorder alloc] initWithServer:self];
    self.connections = [[HALConnectionsRecorder alloc] initWithServer:self];
    self.networkRecorder = [[HALNetworkRecorder alloc] initWithServer:self];

    self.associatedViewController = nil;

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.serverName forKey:@"ServerName"];
    [encoder encodeObject:self.dnsName forKey:@"DnsName"];
    [encoder encodeInt:self.portNumber forKey:@"PortNumber"];
}

#pragma mark Set/change server parameters

- (void)setServerName:(NSString *)serverName
{
    if ([serverName compare:_serverName] != NSOrderedSame) {
        _serverName = serverName;

        if (self.connectionDelegate != nil)
            [self.connectionDelegate serverParameterChanged];
    }
}

- (void)setDnsName:(NSString *)dnsName
{
    if ([dnsName compare:_dnsName] != NSOrderedSame) {
        _dnsName = dnsName;

        if (self.connectionDelegate != nil)
            [self.connectionDelegate serverParameterChanged];
    }
}

- (void)setPortNumber:(UInt16)portNumber
{
    if (portNumber != _portNumber) {
        _portNumber = portNumber;

        if (self.connectionDelegate != nil)
            [self.connectionDelegate serverParameterChanged];
    }
}

#pragma mark Monitoring

- (Boolean)monitoringRunning
{
    return (socket != nil);
}

- (void)startMonitoring
{
    [self connect];
}

- (void)stopMonitoring
{
    self.associatedViewController = nil;

    [self disconnect];

    [self.processorsRecorder resetData];
    [self.mountsRecorder resetData];
    [self.networkRecorder resetData];
    [self.connections resetData];
}

- (void)pauseMonitoring
{
    [self disconnect];
}

#pragma mark Connection

- (void)connect
{
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                        delegateQueue:dispatch_get_main_queue()];
    
    NSString *dnsName;
#ifdef SCREENSHOTING
    if ([self.serverName compare:@"Dr. Zoidberg"] == NSOrderedSame)
        dnsName = @"zoidberg.zeppelinium.de";
    else if ([self.serverName compare:@"DB2"] == NSOrderedSame)
        dnsName = @"zack.fritz.box";
    else
        dnsName = @"zoid.fritz.box";
#else
    dnsName = self.dnsName;
#endif
    
    NSError *error = nil;
    if (![socket connectToHost:dnsName onPort:self.portNumber error:&error])
    {
#ifdef DEBUG
        NSLog(@"Cannot connect: %@", error);
#endif
        
        [self alertSocketError:error.code];
    } else {
        self.cpuRangeTimer = [NSTimer scheduledTimerWithTimeInterval:4.0f
                                                              target:self
                                                            selector:@selector(hearthbeatCPURange)
                                                            userInfo:nil
                                                             repeats:YES];
    }
}

- (void)disconnect
{
    forcedDisconnect = YES;
    
    if (self.cpuRangeTimer != nil) {
        [self.cpuRangeTimer invalidate];
        self.cpuRangeTimer = nil;
    }
    
    [socket disconnect];
}

- (void)hearthbeatCPURange
{
    [self.processorsRecorder recalculateRange];
}

- (void)socket:(GCDAsyncSocket *)sock
didConnectToHost:(NSString *)host
          port:(uint16_t)port
{
#ifdef DEBUG
    NSLog(@"Connected");
#endif

    NSString *requestString = @"gkrellm 2.3.5\r\n";
	NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
	
	[socket writeData:requestData withTimeout:self.connectionTimeout tag:0];
    
    handshaking = YES;
    
    [socket readDataToData:[GCDAsyncSocket LFData] withTimeout:self.connectionTimeout tag:0];

    [self.processorsRecorder serverDidConnect];
    [self.memoryRecorder serverDidConnect];
    [self.swapRecorder serverDidConnect];
    [self.mountsRecorder serverDidConnect];
    [self.networkRecorder serverDidConnect];
    [self.connections serverDidConnect];

    if (self.connectionDelegate != nil)
        [self.connectionDelegate connectedToServer];

    [[HALServerPool sharedServerPool] serverSatusChanged:self];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock
                  withError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"Disconnected: %@", error);
#endif

    socket = nil;

    [self.processorsRecorder serverDidDisconnect];
    [self.memoryRecorder serverDidDisconnect];
    [self.swapRecorder serverDidDisconnect];
    [self.mountsRecorder serverDidDisconnect];
    [self.networkRecorder serverDidDisconnect];
    [self.connections serverDidDisconnect];

    //if (!forcedDisconnect)
    if (error.code != GCDAsyncSocketNoError)
        [self alertSocketError:error.code];
    
    /*[self performSelector:@selector(startMonitoring)
               withObject:nil
               afterDelay:1.0f];*/
    
    forcedDisconnect = NO;

    if (self.connectionDelegate != nil)
        [self.connectionDelegate disconnectedFromServer];

    [[HALServerPool sharedServerPool] serverSatusChanged:self];
}

#pragma mark Network communication

- (void)socket:(GCDAsyncSocket *)sock
   didReadData:(NSData *)data
       withTag:(long)tag
{
	NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([response length] == 1) {
        [socket readDataToData:[GCDAsyncSocket LFData] withTimeout:self.connectionTimeout tag:0];
        return;
    }
    
    response = [response substringToIndex:[response length] - 1];

    if (handshaking) {
        [self processIntroduction:response];
    } else {
        [self processData:response];
    }
    
    [socket readDataToData:[GCDAsyncSocket LFData] withTimeout:self.connectionTimeout tag:0];
}

#pragma mark Parse input information

- (void)processIntroduction:(NSString *)response
{
    if ([response characterAtIndex:0] == '<') {
        if ([response compare:@"<gkrellmd_setup>"] == NSOrderedSame) {
            receivingDataType = HALNotReceiving;
            handshaking = YES;
        } else if ([response compare:@"</gkrellmd_setup>"] == NSOrderedSame) {
            receivingDataType = HALNotReceiving;
            handshaking = NO;
        } else if ([response compare:@"<cpu_setup>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionCPUSetup;
        } else if ([response compare:@"<error>"] == NSOrderedSame) {
            receivingDataType = HALNotReceiving;
            [self alertServerError];
        } else if ([response compare:@"<hostname>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionHostname;
        } else if ([response compare:@"<io_timeout>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionIOTimeout;
        } else if ([response compare:@"<net_setup>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionNetSetup;
        } else if ([response compare:@"<reconnect_timeout>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionReconnectTimeout;
        } else if ([response compare:@"<sysname>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionSystemName;
        } else if ([response compare:@"<uptime>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionUptime;
        } else if ([response compare:@"<version>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionVersion;
        } else if ([response compare:@"<decimal_point>"] == NSOrderedSame) {
            receivingDataType = HALNotReceiving;
        } else if ([response compare:@"<mail_setup>"] == NSOrderedSame) {
            receivingDataType = HALNotReceiving;
        } else if ([response compare:@"<mem>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionMemory;
        } else if ([response compare:@"<monitors>"] == NSOrderedSame) {
            receivingDataType = HALNotReceiving;
        } else if ([response compare:@"<sensors_setup>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionSensors;
        } else if ([response compare:@"<swap>"] == NSOrderedSame) {
            receivingDataType = HALIntroductionSwap;
        } else if ([response compare:@"<time>"] == NSOrderedSame) {
            receivingDataType = HALNotReceiving;
        } else {
            receivingDataType = HALNotReceiving;
#ifdef DEBUG
            NSLog(@"Unknown token: %@", response);
#endif
        }
    } else {
        [self commitIntroductionLine:response];
    }
}

- (void)commitIntroductionLine:(NSString *)line
{
    switch (receivingDataType)
    {
        case HALIntroductionCPUSetup:
            [self.processorsRecorder parseIntroductionLine:line];
            break;
            
        case HALIntroductionHostname:
            self.serverToldHostname = [NSString stringWithString:line];
            break;
            
        case HALIntroductionIOTimeout:
            self.serverToldIOTimeout = [line floatValue];
            break;
            
        case HALIntroductionMemory:
            [self.memoryRecorder parseLine:line];
            break;

        case HALIntroductionNetSetup:
            break;
            
        case HALIntroductionReconnectTimeout:
            self.serverToldReconnectTimeout = [line floatValue];
            break;

        case HALIntroductionSensors:
#ifdef DEBUG
            NSLog(@"%@", line);
#endif
            break;

        case HALIntroductionSwap:
            [self.swapRecorder parseLine:line];
            break;

        case HALIntroductionSystemName:
            self.serverToldSystemName = [NSString stringWithString:line];
            break;
            
        case HALIntroductionUptime:
            [self processDataLineForUptime:line];
            break;
            
        case HALIntroductionVersion:
            self.serverToldVersion = [NSString stringWithString:line];
            break;

        default:
            break;
    }
}

- (void)processData:(NSString *)response
{
    if ([response characterAtIndex:0] == '<') {
        if ([response characterAtIndex:1] == '.') {
            if ((self.monitoringDelegate != nil) && [self.monitoringDelegate respondsToSelector:@selector(clock)])
                [self.monitoringDelegate clock];
        } else if ([response compare:@"<cpu>"] == NSOrderedSame) {
            [self.processorsRecorder nextRecord];
            receivingDataType = HALReceivingCPU;
        } else if ([response compare:@"<disk>"] == NSOrderedSame) {
            receivingDataType = HALReceivingDisk;
        } else if ([response compare:@"<error>"] == NSOrderedSame) {
            receivingDataType = HALNotReceiving;
            [self alertServerError];
        } else if ([response compare:@"<inet>"] == NSOrderedSame) {
            receivingDataType = HALReceivingInet;
        } else if ([response compare:@"<mem>"] == NSOrderedSame) {
            receivingDataType = HALReceivingMemory;
        } else if ([response compare:@"<fs>"] == NSOrderedSame) {
            receivingDataType = HALReceivingMounts;
        } else if ([response compare:@"<fs_mounts>"] == NSOrderedSame) {
            receivingDataType = HALReceivingMounts;
        } else if ([response compare:@"<net>"] == NSOrderedSame) {
            receivingDataType = HALReceivingNet;
        } else if ([response compare:@"<proc>"] == NSOrderedSame) {
            receivingDataType = HALReceivingProc;
        } else if ([response compare:@"<sensors>"] == NSOrderedSame) {
            receivingDataType = HALReceivingSensors;
        } else if ([response compare:@"<swap>"] == NSOrderedSame) {
            receivingDataType = HALReceivingSwap;
        } else if ([response compare:@"<uptime>"] == NSOrderedSame) {
            receivingDataType = HALReceivingUptime;
        } else {
            receivingDataType = HALNotReceiving;
#ifdef DEBUG
            NSLog(@"Unknown token: %@", response);
#endif
        }
    } else {
        [self processDataLine:response];
    }
}

- (void)processDataLine:(NSString *)line
{
    switch (receivingDataType)
    {
        case HALReceivingCPU:
            [self.processorsRecorder parseLine:line];
            break;
            
        case HALReceivingDisk:
            break;
            
        case HALReceivingInet:
            [self.connections parseLine:line];
            break;

        case HALReceivingMemory:
            [self.memoryRecorder parseLine:line];
            break;
        
        case HALReceivingMounts:
            [self.mountsRecorder parseLine:line];
            break;

        case HALReceivingNet:
            [self.networkRecorder parseLine:line];
            break;
            
        case HALReceivingProc:
            break;

        case HALReceivingSensors:
#ifdef DEBUG
            NSLog(@"%@", line);
#endif
            break;

        case HALReceivingSwap:
            [self.swapRecorder parseLine:line];
            break;

        case HALReceivingUptime:
            [self processDataLineForUptime:line];
            break;

        default:
            break;
    }
}

- (void)processDataLineForUptime:(NSString *)line
{
    NSScanner *scanner;
    NSInteger uptime;
    
    scanner = [NSScanner scannerWithString:line];
    [scanner scanInteger:&uptime];
    self.serverUptime = uptime;

    if ((self.monitoringDelegate != nil) && [self.monitoringDelegate respondsToSelector:@selector(serverUptimeReported)])
        [self.monitoringDelegate serverUptimeReported];
}

#pragma mark Error messages

- (void)alertSocketError:(NSInteger)errorCode
{
    switch (errorCode) {
        case 2:
        {
            NSString *title = NSLocalizedString(@"ALERT_TITLE_ERROR", nil);
            NSString *message = NSLocalizedString(@"ALERT_BAD_DNS_NAME", nil);
            NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_OK", nil);
            
            message = [NSString stringWithFormat:message,
                       self.serverName,
                       self.dnsName];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:cancelButton
                                                      otherButtonTitles:nil];
            
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];

            break;
        }

        case 4:
        {
            NSString *title = NSLocalizedString(@"ALERT_TITLE_ERROR", nil);
            NSString *message = NSLocalizedString(@"ALERT_SOCKET_READ_TIMED_OUT", nil);
            NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_IGNORE", nil);
            NSString *submitButton = NSLocalizedString(@"ALERT_BUTTON_RECONNECT", nil);
            
            message = [NSString stringWithFormat:message,
                       self.serverName];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:cancelButton
                                                      otherButtonTitles:submitButton, nil];
            
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];
            
            break;
        }

        case 8:
        {
            NSString *title = NSLocalizedString(@"ALERT_TITLE_ERROR", nil);
            NSString *message = NSLocalizedString(@"ALERT_OTHER_SOCKET_ERROR", nil);
            NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_OK", nil);
            
            message = [NSString stringWithFormat:message,
                       self.serverName,
                       self.dnsName,
                       self.portNumber];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:cancelButton
                                                      otherButtonTitles:nil];
            
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];
            
            break;
        }

        case 60:
        {
            NSString *title = NSLocalizedString(@"ALERT_TITLE_ERROR", nil);
            NSString *message = NSLocalizedString(@"ALERT_CONNECT_TIMED_OUT", nil);
            NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_OK", nil);
            
            message = [NSString stringWithFormat:message,
                       self.serverName];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:cancelButton
                                                      otherButtonTitles:nil];
            
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];
            
            break;
        }

        case 61:
        {
            NSString *title = NSLocalizedString(@"ALERT_TITLE_ERROR", nil);
            NSString *message = NSLocalizedString(@"ALERT_CONNECTION_REFUSED", nil);
            NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_OK", nil);
            
            message = [NSString stringWithFormat:message,
                       self.serverName];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:cancelButton
                                                      otherButtonTitles:nil];
            
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];
            
            break;
        }

        case 65:
        {
            NSString *title = NSLocalizedString(@"ALERT_TITLE_ERROR", nil);
            NSString *message = NSLocalizedString(@"ALERT_NO_ROUTE_TO_HOST", nil);
            NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_OK", nil);
            
            message = [NSString stringWithFormat:message,
                       self.serverName,
                       self.dnsName];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:cancelButton
                                                      otherButtonTitles:nil];
            
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];
            
            break;
        }

        default:
        {
            NSString *title = NSLocalizedString(@"ALERT_TITLE_ERROR", nil);
            NSString *message = NSLocalizedString(@"ALERT_OTHER_SOCKET_ERROR", nil);
            NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_OK", nil);
            
            message = [NSString stringWithFormat:message,
                       self.serverName,
                       self.dnsName,
                       self.portNumber];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:cancelButton
                                                      otherButtonTitles:nil];
            
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];
            
            break;
        }
    }
}

- (void)alertLostConnection
{
    NSString *title = NSLocalizedString(@"ALERT_TITLE_WARNING", nil);
    NSString *message = NSLocalizedString(@"ALERT_CONNECTION_LOST", nil);
    NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_IGNORE", nil);
    NSString *submitButton = NSLocalizedString(@"ALERT_BUTTON_RECONNECT", nil);
    
    message = [NSString stringWithFormat:message,
               self.serverName];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButton
                                              otherButtonTitles:submitButton, nil];
    
    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

- (void)alertServerError
{
    [socket disconnect];
    
    NSString *title = NSLocalizedString(@"ALERT_TITLE_ERROR", nil);
    NSString *message = NSLocalizedString(@"ALERT_SERVER_ERROR", nil);
    NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_OK", nil);

    message = [NSString stringWithFormat:message,
               self.serverName,
               self.serverName];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButton
                                              otherButtonTitles:nil];
    
    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self connect];
}

@end
