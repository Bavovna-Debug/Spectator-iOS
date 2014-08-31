//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALConnectionRecord.h"
#import "HALResourceRecorder.h"

@protocol HALConnectionsRecorderDelegate;

@interface HALConnectionsRecorder : HALResourceRecorder

@property (strong, nonatomic) NSMutableArray *activeConnections;
@property (strong, nonatomic) NSMutableArray *closedConnections;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol HALConnectionsRecorderDelegate <NSObject>

@required

- (void)activeConnectionsCleared;

- (void)activeConnectionAppeared:(HALConnectionRecord *)connection;

- (void)activeConnectionDisappeared:(HALConnectionRecord *)connection;

@end