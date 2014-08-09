//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALResourceRecorder.h"

@interface HALMountsRecorder : HALResourceRecorder

@property (strong, nonatomic) NSMutableArray *mounts;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end
