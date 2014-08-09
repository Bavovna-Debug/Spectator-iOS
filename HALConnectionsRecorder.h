//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALResourceRecorder.h"

@interface HALConnectionsRecorder : HALResourceRecorder

@property (strong, nonatomic) NSMutableArray *activeConnections;
@property (strong, nonatomic) NSMutableArray *closedConnections;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end
