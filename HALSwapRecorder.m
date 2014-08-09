//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALServer.h"
#import "HALSwapRecorder.h"

@interface HALSwapRecorder ()

@property (weak, nonatomic) HALServer *server;

@end

@implementation HALSwapRecorder

- (id)initWithServer:(HALServer *)server
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.server = server;
    
    return self;
}

- (void)parseLine:(NSString *)line
{
    NSArray *parts = [line componentsSeparatedByString:@" "];
    if ([parts count] == 4) {
        long long total;
        long long used;
        
        NSScanner *scanner;
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
        [scanner scanLongLong:&total];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
        [scanner scanLongLong:&used];
        
        self.total = total;
        self.used = used;

        [[NSNotificationCenter defaultCenter] postNotificationName:@"SwapInfoChanged"
                                                            object:self.server];
    }
}

@end
