//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALBarGraphBlock.h"
#import "HALCpuDetailsBarGraph.h"
#import "HALProcessorUsageRecord.h"

@interface HALCpuDetailsBarGraph ()

@property (weak, nonatomic) HALProcessorsRecorder *recorder;
@property (assign, nonatomic) NSUInteger cpuNumber;
@property (strong, nonatomic) HALBarGraphBlock *userBlock;
@property (strong, nonatomic) HALBarGraphBlock *niceBlock;
@property (strong, nonatomic) HALBarGraphBlock *systemBlock;

@end

@implementation HALCpuDetailsBarGraph
{
    CGSize padding;
}

- (id)initWithFrame:(CGRect)frame
           recorder:(HALProcessorsRecorder *)recorder
          cpuNumber:(NSUInteger)cpuNumber
          userColor:(UIColor *)userColor
          niceColor:(UIColor *)niceColor
        systemColor:(UIColor *)systemColor
          idleColor:(UIColor *)idleColor
{
    self = [super initWithFrame:frame
                      graphType:HALBarGraphVertical];
    if (self == nil)
        return nil;

    self.recorder = recorder;
    self.cpuNumber = cpuNumber;

    [self setBackgroundColor:[UIColor blackColor]];

    self.userBlock = [self addBlockWithColor:userColor];
    self.niceBlock = [self addBlockWithColor:niceColor];
    self.systemBlock = [self addBlockWithColor:systemColor];

    [self addLabel:[NSString stringWithFormat:@"Cpu%lu", (unsigned long)cpuNumber]
         textColor:[UIColor whiteColor]];

    return self;
}

- (void)refresh
{
    NSUInteger currentRecordNumber = [[self.recorder history] count] - 1;
    if (currentRecordNumber < 1)
        return;

    NSMutableArray *currentLine = [[self.recorder history] objectAtIndex:currentRecordNumber];
    NSMutableArray *previousLine = [[self.recorder history] objectAtIndex:currentRecordNumber - 1];
    HALProcessorUsageRecord *currentRecord = [currentLine objectAtIndex:self.cpuNumber];
    HALProcessorUsageRecord *previousRecord = [previousLine objectAtIndex:self.cpuNumber];

    UInt64 userTime = [currentRecord userTime] - [previousRecord userTime];
    UInt64 niceTime = [currentRecord niceTime] - [previousRecord niceTime];
    UInt64 systemTime = [currentRecord systemTime] - [previousRecord systemTime];
    UInt64 totalTime = [currentRecord total] - [previousRecord total];

    [self setMaxValue:totalTime];
    [self.userBlock setValue:userTime];
    [self.niceBlock setValue:niceTime];
    [self.systemBlock setValue:systemTime];
    
    [self refreshBlocks];
}

@end
