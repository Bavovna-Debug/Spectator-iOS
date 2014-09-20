//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SRVMemoryRecorder.h"
#import "Server.h"

@interface SRVMemoryRecorder ()

@property (weak, nonatomic) Server *server;

@end

@implementation SRVMemoryRecorder

#pragma mark Object cunstructors/destructors

- (id)initWithServer:(Server *)server
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.server = server;
        
    return self;
}

#pragma mark Parse input information

- (void)parseLine:(NSString *)line
{
    NSArray *parts = [line componentsSeparatedByString:@" "];
    if ([parts count] == 5) {
        long long total;
        long long used;
        long long free;
        long long buffers;
        long long cached;
        
        NSScanner *scanner;
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
        [scanner scanLongLong:&total];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
        [scanner scanLongLong:&used];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:2]];
        [scanner scanLongLong:&free];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:3]];
        [scanner scanLongLong:&buffers];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:4]];
        [scanner scanLongLong:&cached];
        
        self.total = total;
        self.used = used;
        self.free = free;
        self.buffers = buffers;
        self.cached = cached;
    } else if ([parts count] == 6) {
        long long total;
        long long used;
        long long free;
        long long shared;
        long long buffers;
        long long cached;
        
        NSScanner *scanner;
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
        [scanner scanLongLong:&total];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
        [scanner scanLongLong:&used];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:2]];
        [scanner scanLongLong:&free];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:3]];
        [scanner scanLongLong:&shared];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:4]];
        [scanner scanLongLong:&buffers];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:5]];
        [scanner scanLongLong:&cached];
        
        self.total = total;
        self.used = used;
        self.free = free;
        self.shared = shared;
        self.buffers = buffers;
        self.cached = cached;
    } else {
        return;
    }

    if (self.delegate != nil)
        [self.delegate memoryInfoChanged];
}

@end
