//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

#import "SRVConnectionsRecorder.h"
#import "SRVMemoryRecorder.h"
#import "SRVMountsRecorder.h"
#import "SRVNetworkRecorder.h"
#import "SRVProcessorsRecorder.h"
#import "SRVSwapRecorder.h"

#define SCREENSHOTING

@protocol ServerConnectionDelegate;
@protocol ServerMonitoringDelegate;

@interface Server : NSObject <GCDAsyncSocketDelegate, UIAlertViewDelegate>

@property (nonatomic, strong, readwrite) id connectionDelegate;
@property (nonatomic, strong, readwrite) id monitoringDelegate;

@property (strong, nonatomic) NSString        *serverName;
@property (strong, nonatomic) NSString        *dnsName;
@property (assign, nonatomic) UInt16          portNumber;
@property (assign, nonatomic) Boolean         reconnectImmediately;
@property (assign, nonatomic) NSTimeInterval  connectionTimeout;

@property (strong, nonatomic) NSString        *serverToldVersion;
@property (strong, nonatomic) NSString        *serverToldHostname;
@property (strong, nonatomic) NSString        *serverToldSystemName;
@property (assign, nonatomic) CGFloat         serverToldIOTimeout;
@property (assign, nonatomic) CGFloat         serverToldReconnectTimeout;
@property (assign, nonatomic) NSUInteger      serverUptime;

@property (strong, nonatomic) SRVProcessorsRecorder   *processorsRecorder;
@property (strong, nonatomic) SRVMemoryRecorder       *memoryRecorder;
@property (strong, nonatomic) SRVSwapRecorder         *swapRecorder;
@property (strong, nonatomic) SRVMountsRecorder       *mountsRecorder;
@property (strong, nonatomic) SRVNetworkRecorder      *networkRecorder;
@property (strong, nonatomic) SRVConnectionsRecorder  *connections;

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

@protocol ServerConnectionDelegate <NSObject>

@required

- (void)serverParameterChanged;

- (void)connectedToServer;

- (void)disconnectedFromServer;

@end

@protocol ServerMonitoringDelegate <NSObject>

@optional

- (void)clock;

- (void)serverUptimeReported;

@end