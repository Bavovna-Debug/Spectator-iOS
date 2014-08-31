//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALResourceRecorder.h"

@protocol HALSwapRecorderDelegate;

@interface HALSwapRecorder : HALResourceRecorder

@property (assign, nonatomic) UInt64 total;
@property (assign, nonatomic) UInt64 used;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol HALSwapRecorderDelegate <NSObject>

@required

- (void)swapInfoChanged;

@end