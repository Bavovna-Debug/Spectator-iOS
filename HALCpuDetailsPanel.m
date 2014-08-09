//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALCpuDetailsBarGraph.h"
#import "HALCpuDetailsPanel.h"
#import "HALProcessorsRecorder.h"
#import "HALProcessorUsageRecord.h"

@interface HALCpuDetailsPanel ()

@property (weak, nonatomic) HALProcessorsRecorder *recorder;
@property (strong, nonatomic) UIColor *userColor;
@property (strong, nonatomic) UIColor *niceColor;
@property (strong, nonatomic) UIColor *systemColor;
@property (strong, nonatomic) UIColor *idleColor;
@property (strong, nonatomic) UILabel *userLabel;
@property (strong, nonatomic) UILabel *niceLabel;
@property (strong, nonatomic) UILabel *systemLabel;
@property (strong, nonatomic) UILabel *idleLabel;
@property (strong, nonatomic) NSMutableArray *charts;

@end

@implementation HALCpuDetailsPanel
{
    CGRect chartsFrame;
}

- (id)initWithHeight:(CGFloat)height
              title:(NSString *)title
{
    self = [super initWithHeight:height
                          title:title];
    if (self == nil)
        return nil;

    self.recorder = nil;
    self.charts = [NSMutableArray array];

    self.userColor = [UIColor colorWithRed:0.250f green:0.800f blue:0.000f alpha:1.0f];
    self.niceColor = [UIColor colorWithRed:0.000f green:0.000f blue:1.000f alpha:1.0f];
    self.systemColor = [UIColor colorWithRed:1.000f green:0.200f blue:0.200f alpha:1.0f];
    self.idleColor = [UIColor colorWithRed:0.298f green:0.298f blue:0.298f alpha:1.0f];

    NSString *userText = [NSString stringWithString:NSLocalizedString(@"CPU_USAGE_USER", nil)];
    NSString *niceText = [NSString stringWithString:NSLocalizedString(@"CPU_USAGE_NICE", nil)];
    NSString *systemText = [NSString stringWithString:NSLocalizedString(@"CPU_USAGE_SYSTEM", nil)];
    NSString *idleText = [NSString stringWithString:NSLocalizedString(@"CPU_USAGE_IDLE", nil)];

    CGSize padding = [self padding];

    CGRect userFrame;
    CGRect niceFrame;
    CGRect systemFrame;
    CGRect idleFrame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect contentFrame = [self contentFrame];
        CGFloat percentDisplayHeight = 32.0f;

        idleFrame = CGRectMake(CGRectGetMinX(contentFrame),
                               CGRectGetMinY(contentFrame),
                               CGRectGetWidth(contentFrame) / 5,
                               percentDisplayHeight);
        
        systemFrame = CGRectOffset(idleFrame, 0, CGRectGetHeight(idleFrame) + padding.width);
        
        userFrame = CGRectOffset(systemFrame, 0, CGRectGetHeight(systemFrame) + padding.width);
        
        niceFrame = CGRectOffset(userFrame, 0, CGRectGetHeight(userFrame) + padding.width);

        chartsFrame = CGRectMake(CGRectGetMaxX(niceFrame) + padding.width,
                                 CGRectGetMinY(contentFrame),
                                 CGRectGetWidth(contentFrame) - CGRectGetMaxX(niceFrame) - padding.width,
                                 CGRectGetHeight(contentFrame));
    } else {
        CGRect contentFrame = [self contentFrame];
        CGFloat percentDisplayHeight = 18.0f;

        userFrame = CGRectMake(CGRectGetMinX(contentFrame),
                               CGRectGetMinY(contentFrame),
                               CGRectGetWidth(contentFrame) / 2 - padding.width,
                               percentDisplayHeight);

        niceFrame = CGRectOffset(userFrame, CGRectGetWidth(contentFrame) / 2 + padding.width, 0);

        systemFrame = CGRectOffset(userFrame, 0, percentDisplayHeight + padding.height * 0.5f);

        idleFrame = CGRectOffset(systemFrame, CGRectGetWidth(contentFrame) / 2 + padding.width, 0);

        chartsFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                 CGRectGetMaxY(idleFrame) + padding.height,
                                 CGRectGetWidth(contentFrame),
                                 CGRectGetMinY(contentFrame) + CGRectGetHeight(contentFrame) - CGRectGetMaxY(idleFrame) - padding.height);
    }

    self.userLabel = [self addPercentDisplayWithFrame:userFrame
                                                color:self.userColor
                                                 text:userText];

    self.niceLabel = [self addPercentDisplayWithFrame:niceFrame
                                                color:self.niceColor
                                                 text:niceText];

    self.systemLabel = [self addPercentDisplayWithFrame:systemFrame
                                                  color:self.systemColor
                                                   text:systemText];

    self.idleLabel = [self addPercentDisplayWithFrame:idleFrame
                                                color:self.idleColor
                                                 text:idleText];

    return self;
}

- (void)serverDidSet
{
    [super serverDidSet];

    for (HALCpuDetailsBarGraph *chart in self.charts)
    {
        [chart removeFromSuperview];
    }
    
    [self.charts removeAllObjects];
    
    self.recorder = [self.server processorsRecorder];
}

- (void)refresh
{
    [super refresh];

    [self refreshValues];
    [self refreshCharts];
}

- (void)refreshValues
{
    NSUInteger currentRecordNumber = [[self.recorder history] count] - 1;
    if (currentRecordNumber < 1)
        return;
    
    NSMutableArray *currentLine = [[self.recorder history] objectAtIndex:currentRecordNumber];
    NSMutableArray *previousLine = [[self.recorder history] objectAtIndex:currentRecordNumber - 1];
    HALProcessorUsageRecord *currentRecord = [currentLine lastObject];
    HALProcessorUsageRecord *previousRecord = [previousLine lastObject];
    
    UInt64 userTime = [currentRecord userTime] - [previousRecord userTime];
    UInt64 niceTime = [currentRecord niceTime] - [previousRecord niceTime];
    UInt64 systemTime = [currentRecord systemTime] - [previousRecord systemTime];
    UInt64 idleTime = [currentRecord idleTime] - [previousRecord idleTime];
    UInt64 totalTime = [currentRecord total] - [previousRecord total];

    [self.userLabel setText:[NSString stringWithFormat:@"%0.1f %%",
                             ((double)userTime / (double)totalTime) * 100]];
    [self.niceLabel setText:[NSString stringWithFormat:@"%0.1f %%",
                             ((double)niceTime / (double)totalTime) * 100]];
    [self.systemLabel setText:[NSString stringWithFormat:@"%0.1f %%",
                             ((double)systemTime / (double)totalTime) * 100]];
    [self.idleLabel setText:[NSString stringWithFormat:@"%0.1f %%",
                             ((double)idleTime / (double)totalTime) * 100]];
}

- (void)refreshCharts
{
    if ([self.charts count] == 0)
    {
        NSUInteger numberOfProcessors = [self.recorder numberOfProcessors];
        
        CGRect chartFrame = CGRectMake(CGRectGetMinX(chartsFrame),
                                       CGRectGetMinY(chartsFrame),
                                       CGRectGetWidth(chartsFrame) / MAX(4, numberOfProcessors),
                                       CGRectGetHeight(chartsFrame));
        
        for (NSUInteger cpuNumber = 0; cpuNumber < numberOfProcessors; cpuNumber++)
        {
            HALCpuDetailsBarGraph *chart = [[HALCpuDetailsBarGraph alloc] initWithFrame:CGRectInset(chartFrame, 1, 1)
                                                           recorder:self.recorder
                                                          cpuNumber:cpuNumber
                                                          userColor:self.userColor
                                                          niceColor:self.niceColor
                                                        systemColor:self.systemColor
                                                          idleColor:self.idleColor];
            [self.charts addObject:chart];
            [self addSubview:chart];
            
            chartFrame = CGRectOffset(chartFrame, CGRectGetWidth(chartFrame), 0);
        }
    }

    for (HALCpuDetailsBarGraph *chart in self.charts)
    {
        [chart refresh];
    }
}

@end