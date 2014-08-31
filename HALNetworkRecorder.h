//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALNetworkInterface.h"
#import "HALResourceRecorder.h"

@protocol HALNetworkRecorderDelegate;

@interface HALNetworkRecorder : HALResourceRecorder

@property (strong, nonatomic) NSMutableArray *interfaces;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol HALNetworkRecorderDelegate <NSObject>

@required

- (void)networkInterfacesReset;

- (void)networkInterfaceDetected:(HALNetworkInterface *)interface;

- (void)networkTrafficChanged:(HALNetworkInterface *)interface;

@end