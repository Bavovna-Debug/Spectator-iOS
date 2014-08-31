//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALMount.h"
#import "HALResourceRecorder.h"

@protocol HALMountsRecorderDelegate;

@interface HALMountsRecorder : HALResourceRecorder

@property (strong, nonatomic) NSMutableArray *mounts;

- (id)initWithServer:(NSObject *)server;

- (void)parseLine:(NSString *)line;

@end

@protocol HALMountsRecorderDelegate <NSObject>

@required

- (void)mountsReset;

- (void)mountDetected:(HALMount *)mount;

- (void)mountChanged:(HALMount *)mount;

@end