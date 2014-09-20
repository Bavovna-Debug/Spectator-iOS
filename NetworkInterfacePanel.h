//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Panel.h"

#import "SRVNetworkInterface.h"

@interface NetworkInterfacePanel : Panel

@property (strong, nonatomic) SRVNetworkInterface *interface;

- (id)initWithInterface:(SRVNetworkInterface *)interface;

- (void)refresh;

- (void)refreshStopwatch;

@end
