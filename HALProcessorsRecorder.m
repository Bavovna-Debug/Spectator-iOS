//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALProcessorsRecorder.h"
#import "HALProcessorUsageRecord.h"
#import "HALServer.h"

@interface HALProcessorsRecorder ()

@property (weak, nonatomic) HALServer *server;
@property (strong, nonatomic) NSMutableArray *currentRecord;

@end

@implementation HALProcessorsRecorder

- (id)initWithServer:(HALServer *)server
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.server = server;
    
    [self resetData];
    
    return self;
}

- (void)resetData
{
    [super resetData];

    self.numberOfProcessors = 0;
    self.history = [NSMutableArray array];
    self.fullLoadRange = 0.0f;
    
    self.currentRecord = [NSMutableArray array];
}

- (void)parseIntroductionLine:(NSString *)line;
{
    NSArray *parts = [line componentsSeparatedByString:@" "];
    if ([parts count] != 2)
        return;
    
    NSString *label = [parts objectAtIndex:0];
    NSString *value = [parts objectAtIndex:1];
    
    if ([label compare:@"n_cpus"] != NSOrderedSame)
        return;
    
    self.numberOfProcessors = [value integerValue];
}

- (void)nextRecord
{
    if ([self.currentRecord count] == self.numberOfProcessors)
    {
        HALProcessorUsageRecord *summaryRecord = [[HALProcessorUsageRecord alloc] init];
        for (HALProcessorUsageRecord *cpuRecord in self.currentRecord)
        {
            [summaryRecord addUserTime:[cpuRecord usedTime]
                              niceTime:[cpuRecord niceTime]
                            systemTime:[cpuRecord systemTime]
                              idleTime:[cpuRecord idleTime]];
        }
        [self.currentRecord addObject:summaryRecord];
        
        [self.history addObject:self.currentRecord];

        if ([self.history count] < 40)
            [self recalculateRange];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClockProcessor"
                                                            object:self.server];
    }

    self.currentRecord = [NSMutableArray array];
}

- (void)parseLine:(NSString *)line
{
    NSArray *parts = [line componentsSeparatedByString:@" "];
    if ([parts count] != 5)
        return;

    NSInteger processorId;
    
    long long userTime;
    long long niceTime;
    long long systemTime;
    long long idleTime;
    
    NSScanner *scanner;
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
    [scanner scanInteger:&processorId];
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
    [scanner scanLongLong:&userTime];

    scanner = [NSScanner scannerWithString:[parts objectAtIndex:2]];
    [scanner scanLongLong:&niceTime];

    scanner = [NSScanner scannerWithString:[parts objectAtIndex:3]];
    [scanner scanLongLong:&systemTime];

    scanner = [NSScanner scannerWithString:[parts objectAtIndex:4]];
    [scanner scanLongLong:&idleTime];
    
    HALProcessorUsageRecord *processorRecord;
    processorRecord = [[HALProcessorUsageRecord alloc] initWithProcessorId:processorId
                                                                  userTime:userTime
                                                                  niceTime:niceTime
                                                                systemTime:systemTime
                                                                  idleTime:idleTime];

    [self.currentRecord insertObject:processorRecord atIndex:processorId];
}

- (void)recalculateRange
{
    NSInteger numberOfRecords = [self.history count];
    if (numberOfRecords == 0)
        return;
    
    NSUInteger recordsToAnalyse = 50;

    NSInteger toRecordNumber = numberOfRecords - 1;

    NSInteger fromRecordNumber = toRecordNumber - recordsToAnalyse;
    while (fromRecordNumber < 0)
    {
        fromRecordNumber++;
        recordsToAnalyse--;
    }
    
    CGFloat summary = 0.0f;
    UInt64 lastTotal = 0;
    for (NSInteger recordNumber = fromRecordNumber; recordNumber <= toRecordNumber; recordNumber++)
    {
        NSMutableArray *records = [self.history objectAtIndex:recordNumber];
        HALProcessorUsageRecord *record = [records lastObject];
        
        UInt64 thisTotal = [record idleTime] + [record usedTime];
        if (thisTotal == 0) {
            recordsToAnalyse--;
            continue;
        }

        if (lastTotal > 0) {
            summary += thisTotal - lastTotal;
        }
        
        lastTotal = thisTotal;
    }
    
    self.fullLoadRange = summary / (double)recordsToAnalyse;
}

@end
