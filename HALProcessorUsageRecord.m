//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALProcessorUsageRecord.h"

@implementation HALProcessorUsageRecord

#pragma mark Object cunstructors/destructors

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.processorId    = -1;
    self.userTime       = 0;
    self.niceTime       = 0;
    self.systemTime     = 0;
    self.idleTime       = 0;
    
    self.usedTime       = 0;
    
    return self;
}

- (id)initWithProcessorId:(NSInteger)processorId
                 userTime:(UInt64)userTime
                 niceTime:(UInt64)niceTime
               systemTime:(UInt64)systemTime
                 idleTime:(UInt64)idleTime
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.processorId    = processorId;
    self.userTime       = userTime;
    self.niceTime       = niceTime;
    self.systemTime     = systemTime;
    self.idleTime       = idleTime;
    
    self.usedTime       = userTime + niceTime + systemTime;
    
    return self;
}

#pragma mark Class specific

- (void)addUserTime:(UInt64)userTime
           niceTime:(UInt64)niceTime
         systemTime:(UInt64)systemTime
           idleTime:(UInt64)idleTime
{
    self.userTime       += userTime;
    self.niceTime       += niceTime;
    self.systemTime     += systemTime;
    self.idleTime       += idleTime;

    self.usedTime       += userTime + niceTime + systemTime;
}

- (UInt64)total
{
    return self.usedTime + self.idleTime;
}

@end
