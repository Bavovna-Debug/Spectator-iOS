//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Server.h"
#import "ServerPool.h"

typedef enum {
    XMLNotReceiving,
    
    XMLIntroductionCPUSetup,
    XMLIntroductionHostname,
    XMLIntroductionIOTimeout,
    XMLIntroductionMemory,
    XMLIntroductionNetSetup,
    XMLIntroductionReconnectTimeout,
    XMLIntroductionSensors,
    XMLIntroductionSwap,
    XMLIntroductionSystemName,
    XMLIntroductionUptime,
    XMLIntroductionVersion,
    
    XMLReceivingCPU,
    XMLReceivingDisk,
    XMLReceivingInet,
    XMLReceivingMemory,
    XMLReceivingMounts,
    XMLReceivingNet,
    XMLReceivingProc,
    XMLReceivingSensors,
    XMLReceivingSwap,
    XMLReceivingUptime
} XMLReceivingDataType;

@interface Server ()

@property (strong, nonatomic) NSTimer *cpuRangeTimer;

@end

@implementation Server
{
    GCDAsyncSocket *socket;
    Boolean forcedDisconnect;
    Boolean handshaking;
    XMLReceivingDataType receivingDataType;
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

    self.serverName            = serverName;
    self.dnsName               = dnsName;
    self.portNumber            = 19150;
    self.reconnectImmediately  = YES;
    self.connectionTimeout     = 5.0f;
    
    self.cpuRangeTimer = nil;
    
    socket             = nil;
    forcedDisconnect   = NO;
    handshaking        = NO;
    receivingDataType  = XMLNotReceiving;

    self.serverToldVersion           = nil;
    self.serverToldHostname          = nil;
    self.serverToldSystemName        = nil;
    self.serverToldIOTimeout         = 0.0f;
    self.serverToldReconnectTimeout  = 0.0f;
    self.serverUptime                = 0;
    
    self.processorsRecorder  = [[SRVProcessorsRecorder alloc]   initWithServer:self];
    self.memoryRecorder      = [[SRVMemoryRecorder alloc]       initWithServer:self];
    self.swapRecorder        = [[SRVSwapRecorder alloc]         initWithServer:self];
    self.mountsRecorder      = [[SRVMountsRecorder alloc]       initWithServer:self];
    self.connections         = [[SRVConnectionsRecorder alloc]  initWithServer:self];
    self.networkRecorder     = [[SRVNetworkRecorder alloc]      initWithServer:self];
        
    self.associatedViewController = nil;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self == nil)
        return nil;

    self.serverName            = [decoder decodeObjectForKey:@"ServerName"];
    self.dnsName               = [decoder decodeObjectForKey:@"DnsName"];
    self.portNumber            = [decoder decodeIntForKey:@"PortNumber"];
    self.reconnectImmediately  = [decoder decodeBoolForKey:@"ReconnectImmediately"];

    self.connectionTimeout = 5.0f;
    
    self.cpuRangeTimer = nil;
    
    socket             = nil;
    forcedDisconnect   = NO;
    handshaking        = NO;
    receivingDataType  = XMLNotReceiving;
    
    self.serverToldVersion           = nil;
    self.serverToldHostname          = nil;
    self.serverToldSystemName        = nil;
    self.serverToldIOTimeout         = 0.0f;
    self.serverToldReconnectTimeout  = 0.0f;
    self.serverUptime                = 0;
    
    self.processorsRecorder  = [[SRVProcessorsRecorder alloc]   initWithServer:self];
    self.memoryRecorder      = [[SRVMemoryRecorder alloc]       initWithServer:self];
    self.swapRecorder        = [[SRVSwapRecorder alloc]         initWithServer:self];
    self.mountsRecorder      = [[SRVMountsRecorder alloc]       initWithServer:self];
    self.connections         = [[SRVConnectionsRecorder alloc]  initWithServer:self];
    self.networkRecorder     = [[SRVNetworkRecorder alloc]      initWithServer:self];

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

    [self.processorsRecorder  resetData];
    [self.mountsRecorder      resetData];
    [self.networkRecorder     resetData];
    [self.connections         resetData];
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

    [socket setIPv4Enabled:YES];
    [socket setIPv6Enabled:YES];

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

    [self.processorsRecorder  serverDidConnect];
    [self.memoryRecorder      serverDidConnect];
    [self.swapRecorder        serverDidConnect];
    [self.mountsRecorder      serverDidConnect];
    [self.networkRecorder     serverDidConnect];
    [self.connections         serverDidConnect];

    if (self.connectionDelegate != nil)
        [self.connectionDelegate connectedToServer];

    [[ServerPool sharedServerPool] serverSatusChanged:self];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock
                  withError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"Disconnected: %@", error);
#endif

    socket = nil;

    [self.processorsRecorder  serverDidDisconnect];
    [self.memoryRecorder      serverDidDisconnect];
    [self.swapRecorder        serverDidDisconnect];
    [self.mountsRecorder      serverDidDisconnect];
    [self.networkRecorder     serverDidDisconnect];
    [self.connections         serverDidDisconnect];

    //if (!forcedDisconnect)
    if (error.code != GCDAsyncSocketNoError)
        [self alertSocketError:error.code];
    
    /*[self performSelector:@selector(startMonitoring)
               withObject:nil
               afterDelay:1.0f];*/
    
    forcedDisconnect = NO;

    if (self.connectionDelegate != nil)
        [self.connectionDelegate disconnectedFromServer];

    [[ServerPool sharedServerPool] serverSatusChanged:self];
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
            receivingDataType = XMLNotReceiving;
            handshaking = YES;
        } else if ([response compare:@"</gkrellmd_setup>"] == NSOrderedSame) {
            receivingDataType = XMLNotReceiving;
            handshaking = NO;
        } else if ([response compare:@"<cpu_setup>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionCPUSetup;
        } else if ([response compare:@"<error>"] == NSOrderedSame) {
            receivingDataType = XMLNotReceiving;
            [self alertServerError];
        } else if ([response compare:@"<hostname>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionHostname;
        } else if ([response compare:@"<io_timeout>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionIOTimeout;
        } else if ([response compare:@"<net_setup>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionNetSetup;
        } else if ([response compare:@"<reconnect_timeout>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionReconnectTimeout;
        } else if ([response compare:@"<sysname>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionSystemName;
        } else if ([response compare:@"<uptime>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionUptime;
        } else if ([response compare:@"<version>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionVersion;
        } else if ([response compare:@"<decimal_point>"] == NSOrderedSame) {
            receivingDataType = XMLNotReceiving;
        } else if ([response compare:@"<mail_setup>"] == NSOrderedSame) {
            receivingDataType = XMLNotReceiving;
        } else if ([response compare:@"<mem>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionMemory;
        } else if ([response compare:@"<monitors>"] == NSOrderedSame) {
            receivingDataType = XMLNotReceiving;
        } else if ([response compare:@"<sensors_setup>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionSensors;
        } else if ([response compare:@"<swap>"] == NSOrderedSame) {
            receivingDataType = XMLIntroductionSwap;
        } else if ([response compare:@"<time>"] == NSOrderedSame) {
            receivingDataType = XMLNotReceiving;
        } else {
            receivingDataType = XMLNotReceiving;
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
        case XMLIntroductionCPUSetup:
            [self.processorsRecorder parseIntroductionLine:line];
            break;
            
        case XMLIntroductionHostname:
            self.serverToldHostname = [NSString stringWithString:line];
            break;
            
        case XMLIntroductionIOTimeout:
            self.serverToldIOTimeout = [line floatValue];
            break;
            
        case XMLIntroductionMemory:
            [self.memoryRecorder parseLine:line];
            break;

        case XMLIntroductionNetSetup:
            break;
            
        case XMLIntroductionReconnectTimeout:
            self.serverToldReconnectTimeout = [line floatValue];
            break;

        case XMLIntroductionSensors:
#ifdef DEBUG
            NSLog(@"%@", line);
#endif
            break;

        case XMLIntroductionSwap:
            [self.swapRecorder parseLine:line];
            break;

        case XMLIntroductionSystemName:
            self.serverToldSystemName = [NSString stringWithString:line];
            break;
            
        case XMLIntroductionUptime:
            [self processDataLineForUptime:line];
            break;
            
        case XMLIntroductionVersion:
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
            receivingDataType = XMLReceivingCPU;
        } else if ([response compare:@"<disk>"] == NSOrderedSame) {
            receivingDataType = XMLReceivingDisk;
        } else if ([response compare:@"<error>"] == NSOrderedSame) {
            receivingDataType = XMLNotReceiving;
            [self alertServerError];
        } else if ([response compare:@"<inet>"] == NSOrderedSame) {
            receivingDataType = XMLReceivingInet;
        } else if ([response compare:@"<mem>"] == NSOrderedSame) {
            receivingDataType = XMLReceivingMemory;
        } else if ([response compare:@"<fs>"] == NSOrderedSame) {
            receivingDataType = XMLReceivingMounts;
        } else if ([response compare:@"<fs_mounts>"] == NSOrderedSame) {
            receivingDataType = XMLReceivingMounts;
        } else if ([response compare:@"<net>"] == NSOrderedSame) {
            receivingDataType = XMLReceivingNet;
        } else if ([response compare:@"<proc>"] == NSOrderedSame) {
            receivingDataType = XMLReceivingProc;
        } else if ([response compare:@"<sensors>"] == NSOrderedSame) {
            receivingDataType = XMLReceivingSensors;
        } else if ([response compare:@"<swap>"] == NSOrderedSame) {
            receivingDataType = XMLReceivingSwap;
        } else if ([response compare:@"<uptime>"] == NSOrderedSame) {
            receivingDataType = XMLReceivingUptime;
        } else {
            receivingDataType = XMLNotReceiving;
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
        case XMLReceivingCPU:
            [self.processorsRecorder parseLine:line];
            break;
            
        case XMLReceivingDisk:
            break;
            
        case XMLReceivingInet:
            [self.connections parseLine:line];
            break;

        case XMLReceivingMemory:
            [self.memoryRecorder parseLine:line];
            break;
        
        case XMLReceivingMounts:
            [self.mountsRecorder parseLine:line];
            break;

        case XMLReceivingNet:
            [self.networkRecorder parseLine:line];
            break;
            
        case XMLReceivingProc:
            break;

        case XMLReceivingSensors:
#ifdef DEBUG
            NSLog(@"%@", line);
#endif
            break;

        case XMLReceivingSwap:
            [self.swapRecorder parseLine:line];
            break;

        case XMLReceivingUptime:
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
