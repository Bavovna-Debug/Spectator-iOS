//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALMount.h"

@implementation HALMount

- (id)initWithDeviceName:(NSString *)deviceName
              mountPoint:(NSString *)mountPoint
              fileSystem:(NSString *)fileSystem
               blockSize:(NSUInteger)blockSize
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.deviceName = deviceName;
    self.mountPoint = mountPoint;
    self.fileSystem = fileSystem;
    self.blockSize  = blockSize;

    return self;
}

@end
