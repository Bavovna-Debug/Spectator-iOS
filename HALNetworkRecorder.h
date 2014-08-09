//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALResourceRecorder.h"

@interface HALNetworkRecorder : HALResourceRecorder

@property (strong, nonatomic) NSMutableArray *interfaces;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end
