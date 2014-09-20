//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SRVMountRecord.h"
#import "SRVResourceRecorder.h"

@protocol SRVMountsRecorderDelegate;

@interface SRVMountsRecorder : SRVResourceRecorder

@property (strong, nonatomic) NSMutableArray *mounts;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol SRVMountsRecorderDelegate <NSObject>

@required

- (void)mountsReset;

- (void)mountDetected:(SRVMountRecord *)mount;

- (void)mountChanged:(SRVMountRecord *)mount;

@end