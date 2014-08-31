//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALResourceRecorder.h"

@protocol HALMemoryRecorderDelegate;

@interface HALMemoryRecorder : HALResourceRecorder

@property (assign, nonatomic) UInt64 total;
@property (assign, nonatomic) UInt64 used;
@property (assign, nonatomic) UInt64 free;
@property (assign, nonatomic) UInt64 shared;
@property (assign, nonatomic) UInt64 buffers;
@property (assign, nonatomic) UInt64 cached;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol HALMemoryRecorderDelegate <NSObject>

@required

- (void)memoryInfoChanged;

@end