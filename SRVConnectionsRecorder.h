//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SRVConnectionRecord.h"
#import "SRVResourceRecorder.h"

@protocol SRVConnectionsRecorderDelegate;

@interface SRVConnectionsRecorder : SRVResourceRecorder

@property (strong, nonatomic) NSMutableArray *activeConnections;
@property (strong, nonatomic) NSMutableArray *closedConnections;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol SRVConnectionsRecorderDelegate <NSObject>

@required

- (void)activeConnectionsCleared;

- (void)activeConnectionAppeared:(SRVConnectionRecord *)connection;

- (void)activeConnectionDisappeared:(SRVConnectionRecord *)connection;

@end