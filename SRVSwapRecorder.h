//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SRVResourceRecorder.h"

@protocol SRVSwapRecorderDelegate;

@interface SRVSwapRecorder : SRVResourceRecorder

@property (assign, nonatomic) UInt64 total;
@property (assign, nonatomic) UInt64 used;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol SRVSwapRecorderDelegate <NSObject>

@required

- (void)swapInfoChanged;

@end