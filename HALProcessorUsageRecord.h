//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HALProcessorUsageRecord : NSObject

@property (assign, nonatomic) NSInteger processorId;
@property (assign, nonatomic) UInt64 userTime;
@property (assign, nonatomic) UInt64 niceTime;
@property (assign, nonatomic) UInt64 systemTime;
@property (assign, nonatomic) UInt64 idleTime;
@property (assign, nonatomic) UInt64 usedTime;

- (id)init;

- (id)initWithProcessorId:(NSInteger)processorId
                 userTime:(UInt64)userTime
                 niceTime:(UInt64)niceTime
               systemTime:(UInt64)systemTime
                 idleTime:(UInt64)idleTime;

- (void)addUserTime:(UInt64)userTime
           niceTime:(UInt64)niceTime
         systemTime:(UInt64)systemTime
           idleTime:(UInt64)idleTime;

- (UInt64)total;

@end
