//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRVMountRecord : NSObject

@property (strong, nonatomic) NSString    *deviceName;
@property (strong, nonatomic) NSString    *mountPoint;
@property (strong, nonatomic) NSString    *fileSystem;
@property (assign, nonatomic) NSUInteger  blockSize;
@property (assign, nonatomic) NSUInteger  totalBlocks;
@property (assign, nonatomic) NSUInteger  availableBlocks;
@property (assign, nonatomic) NSUInteger  freeBlocks;

- (id)initWithDeviceName:(NSString *)deviceName
              mountPoint:(NSString *)mountPoint
              fileSystem:(NSString *)fileSystem
               blockSize:(NSUInteger)blockSize;

@end
