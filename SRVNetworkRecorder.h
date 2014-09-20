//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SRVNetworkInterface.h"
#import "SRVResourceRecorder.h"

@protocol SRVNetworkRecorderDelegate;

@interface SRVNetworkRecorder : SRVResourceRecorder

@property (strong, nonatomic) NSMutableArray *interfaces;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol SRVNetworkRecorderDelegate <NSObject>

@required

- (void)networkInterfacesReset;

- (void)networkInterfaceDetected:(SRVNetworkInterface *)interface;

- (void)networkTrafficChanged:(SRVNetworkInterface *)interface;

@end