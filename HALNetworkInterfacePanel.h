//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALNetworkInterface.h"
#import "HALPanel.h"

@interface HALNetworkInterfacePanel : HALPanel

@property (strong, nonatomic) HALNetworkInterface *interface;

- (id)initWithInterface:(HALNetworkInterface *)interface;

- (void)refresh;

- (void)refreshStopwatch;

@end
