//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SRVResourceRecorder.h"

@protocol SRVProcessorsRecorderDelegate;

@interface SRVProcessorsRecorder : SRVResourceRecorder

@property (assign, nonatomic) NSUInteger numberOfProcessors;
@property (strong, nonatomic) NSMutableArray *history;
@property (assign, nonatomic) CGFloat fullLoadRange;

- (id)initWithServer:(NSObject *)server;

- (void)parseIntroductionLine:(NSString *)line;

- (void)nextRecord;

- (void)parseLine:(NSString *)line;

- (void)recalculateRange;

@end

@protocol SRVProcessorsRecorderDelegate <NSObject>

@required

- (void)clockProcessor;

@end