//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

#import "HALConnectionsRecorder.h"
#import "HALMemoryRecorder.h"
#import "HALMountsRecorder.h"
#import "HALNetworkRecorder.h"
#import "HALProcessorsRecorder.h"
#import "HALSwapRecorder.h"

#undef SCREENSHOTING

@interface HALServer : NSObject <GCDAsyncSocketDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *serverName;
@property (strong, nonatomic) NSString *dnsName;
@property (assign, nonatomic) UInt16 portNumber;
@property (assign, nonatomic) Boolean reconnectImmediately;
@property (assign, nonatomic) NSTimeInterval connectionTimeout;

@property (strong, nonatomic) NSString *serverToldVersion;
@property (strong, nonatomic) NSString *serverToldHostname;
@property (strong, nonatomic) NSString *serverToldSystemName;
@property (assign, nonatomic) CGFloat serverToldIOTimeout;
@property (assign, nonatomic) CGFloat serverToldReconnectTimeout;
@property (assign, nonatomic) NSUInteger serverUptime;

@property (strong, nonatomic) HALProcessorsRecorder *processorsRecorder;
@property (strong, nonatomic) HALMemoryRecorder *memoryRecorder;
@property (strong, nonatomic) HALSwapRecorder *swapRecorder;
@property (strong, nonatomic) HALMountsRecorder *mountsRecorder;
@property (strong, nonatomic) HALNetworkRecorder *networkRecorder;
@property (strong, nonatomic) HALConnectionsRecorder *connections;

@property (strong, nonatomic) UIViewController *associatedViewController;

- (id)initWithName:(NSString *)serverName
           dnsName:(NSString *)dnsName;

- (id)initWithCoder:(NSCoder *)decoder;

- (void)encodeWithCoder:(NSCoder *)encoder;

- (void)setServerName:(NSString *)serverName;

- (void)setDnsName:(NSString *)dnsName;

- (void)setPortNumber:(UInt16)portNumber;

- (Boolean)monitoringRunning;

- (void)startMonitoring;

- (void)stopMonitoring;

- (void)pauseMonitoring;

@end
