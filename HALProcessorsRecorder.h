//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALResourceRecorder.h"

@interface HALProcessorsRecorder : HALResourceRecorder

@property (assign, nonatomic) NSUInteger numberOfProcessors;
@property (strong, nonatomic) NSMutableArray *history;
@property (assign, nonatomic) CGFloat fullLoadRange;

- (id)initWithServer:(NSObject *)server;

- (void)parseIntroductionLine:(NSString *)line;

- (void)nextRecord;

- (void)parseLine:(NSString *)line;

- (void)recalculateRange;

@end
