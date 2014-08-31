//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALMountsRecorder.h"
#import "HALServer.h"

@interface HALMountsRecorder ()

@property (weak, nonatomic) HALServer *server;

@end

@implementation HALMountsRecorder

#pragma mark Object cunstructors/destructors

- (id)initWithServer:(HALServer *)server
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.server = server;

    [self resetData];

    return self;
}

#pragma mark Virtual methods

- (void)resetData
{
    [super resetData];

    self.mounts = [NSMutableArray array];

    if (self.delegate != nil)
        [self.delegate mountsReset];
}

- (void)serverDidConnect
{
    [super serverDidConnect];

    [self.mounts removeAllObjects];

    if (self.delegate != nil)
        [self.delegate mountsReset];
}

#pragma mark Parse input information

- (void)parseLine:(NSString *)line
{
    NSArray *parts = [line componentsSeparatedByString:@" "];
    if ([parts count] == 7) {
        [self parseMountDefinition:parts];
    } else if ([parts count] == 6) {
        [self parseMountUpdate:parts];
    }
}

- (void)parseMountDefinition:(NSArray *)parts
{
    NSString *mountPoint = [parts objectAtIndex:0];
    NSString *deviceName = [parts objectAtIndex:1];
    NSString *fileSystem = [parts objectAtIndex:2];

    mountPoint = [NSString stringWithString:mountPoint];
    deviceName = [NSString stringWithString:deviceName];
    fileSystem = [NSString stringWithString:fileSystem];
    
    NSInteger totalBlocks;
    NSInteger availableBlocks;
    NSInteger freeBlocks;
    NSInteger blockSize;

    NSScanner *scanner;
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:3]];
    [scanner scanInteger:&totalBlocks];

    scanner = [NSScanner scannerWithString:[parts objectAtIndex:4]];
    [scanner scanInteger:&availableBlocks];
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:5]];
    [scanner scanInteger:&freeBlocks];
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:6]];
    [scanner scanInteger:&blockSize];
    
    if (totalBlocks != 0) {
        HALMount *mount = [[HALMount alloc] initWithDeviceName:deviceName
                                                    mountPoint:mountPoint
                                                    fileSystem:fileSystem
                                                     blockSize:blockSize];
        [mount setTotalBlocks:totalBlocks];
        [mount setAvailableBlocks:availableBlocks];
        [mount setFreeBlocks:freeBlocks];
        
        [self.mounts addObject:mount];

        if (self.delegate != nil)
            [self.delegate mountDetected:mount];
    }
}

- (void)parseMountUpdate:(NSArray *)parts
{
    NSString *mountPoint = [parts objectAtIndex:0];
    
    NSInteger totalBlocks;
    NSInteger availableBlocks;
    NSInteger freeBlocks;
    NSInteger blockSize;
    
    NSScanner *scanner;
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:2]];
    [scanner scanInteger:&totalBlocks];
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:3]];
    [scanner scanInteger:&availableBlocks];
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:4]];
    [scanner scanInteger:&freeBlocks];
    
    scanner = [NSScanner scannerWithString:[parts objectAtIndex:5]];
    [scanner scanInteger:&blockSize];
    
    for (HALMount *mount in self.mounts)
    {
        if ([[mount mountPoint] compare:mountPoint] == NSOrderedSame) {
            [mount setTotalBlocks:totalBlocks];
            [mount setAvailableBlocks:availableBlocks];
            [mount setFreeBlocks:freeBlocks];
            [mount setBlockSize:blockSize];

            if (self.delegate != nil)
                [self.delegate mountChanged:mount];
            break;
        }
    }
}

@end
