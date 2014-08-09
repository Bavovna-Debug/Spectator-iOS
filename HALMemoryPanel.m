//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALBarGraph.h"
#import "HALBarGraphBlock.h"
#import "HALMemoryPanel.h"
#import "HALMemoryRecorder.h"

@interface HALMemoryPanel ()

@property (strong, nonatomic) HALBarGraph *barGraph;
@property (strong, nonatomic) UILabel *buffersLabel;
@property (strong, nonatomic) UILabel *cachedLabel;
@property (strong, nonatomic) UILabel *usedLabel;
@property (strong, nonatomic) UILabel *freeLabel;
@property (strong, nonatomic) HALBarGraphBlock *buffersBlock;
@property (strong, nonatomic) HALBarGraphBlock *cachedBlock;
@property (strong, nonatomic) HALBarGraphBlock *usedBlock;
@property (strong, nonatomic) HALBarGraphBlock *freeBlock;

@end

@implementation HALMemoryPanel

- (id)initWithHeight:(CGFloat)height
              title:(NSString *)title
{
    self = [super initWithHeight:height
                           title:title];
    if (self == nil)
        return nil;

    UIColor *buffersColor = [UIColor colorWithRed:1.000f green:0.500f blue:0.000f alpha:1.0f];
    UIColor *cachedColor = [UIColor colorWithRed:0.000f green:0.500f blue:1.000f alpha:1.0f];
    UIColor *usedColor = [UIColor colorWithRed:1.000f green:0.200f blue:0.200f alpha:1.0f];
    UIColor *freeColor = [UIColor colorWithRed:0.250f green:0.800f blue:0.000f alpha:1.0f];

    NSString *buffersText = [NSString stringWithString:NSLocalizedString(@"MEMORY_BUFFERS", nil)];
    NSString *cachedText = [NSString stringWithString:NSLocalizedString(@"MEMORY_CACHED", nil)];
    NSString *usedText = [NSString stringWithString:NSLocalizedString(@"MEMORY_USED", nil)];
    NSString *freeText = [NSString stringWithString:NSLocalizedString(@"MEMORY_FREE", nil)];
    
    CGSize padding = [self padding];
    
    CGRect buffersFrame;
    CGRect cachedFrame;
    CGRect usedFrame;
    CGRect freeFrame;
    CGRect chartFrame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect contentFrame = [self contentFrame];
        CGFloat percentDisplayHeight = 22.0f;
        
        buffersFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                  CGRectGetMinY(contentFrame),
                                  (CGRectGetWidth(contentFrame) - padding.width * 3) / 4,
                                  percentDisplayHeight);
        
        cachedFrame = CGRectOffset(buffersFrame, CGRectGetWidth(buffersFrame) + padding.width, 0);
        
        usedFrame = CGRectOffset(cachedFrame, CGRectGetWidth(cachedFrame) + padding.width, 0);
        
        freeFrame = CGRectOffset(usedFrame, CGRectGetWidth(usedFrame) + padding.width, 0);

        chartFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                CGRectGetMaxY(freeFrame) + padding.height,
                                CGRectGetWidth(contentFrame),
                                CGRectGetMaxY(contentFrame) - (CGRectGetMaxY(freeFrame) + padding.height));
    } else {
        CGRect contentFrame = [self contentFrame];
        CGFloat percentDisplayHeight = 18.0f;
        
        buffersFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                  CGRectGetMinY(contentFrame),
                                  CGRectGetWidth(contentFrame) / 2 - padding.width,
                                  percentDisplayHeight);
        
        cachedFrame = CGRectOffset(buffersFrame, CGRectGetWidth(contentFrame) / 2 + padding.width, 0);
        
        usedFrame = CGRectOffset(buffersFrame, 0, percentDisplayHeight + padding.height * 0.5f);
        
        freeFrame = CGRectOffset(usedFrame, CGRectGetWidth(contentFrame) / 2 + padding.width, 0);
        
        chartFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                CGRectGetMaxY(freeFrame) + padding.height,
                                CGRectGetWidth(contentFrame),
                                CGRectGetMaxY(contentFrame) - (CGRectGetMaxY(freeFrame) + padding.height));

    }
    
    self.buffersLabel = [self addPercentDisplayWithFrame:buffersFrame
                                                   color:buffersColor
                                                    text:buffersText];
    
    self.cachedLabel = [self addPercentDisplayWithFrame:cachedFrame
                                                  color:cachedColor
                                                   text:cachedText];
    
    self.usedLabel = [self addPercentDisplayWithFrame:usedFrame
                                                    color:usedColor
                                                    text:usedText];
    
    self.freeLabel = [self addPercentDisplayWithFrame:freeFrame
                                                    color:freeColor
                                                    text:freeText];

    self.barGraph = [[HALBarGraph alloc] initWithFrame:chartFrame
                                             graphType:HALBarGraphHorizontal
                                          defaultColor:[UIColor greenColor]];
    [self addSubview:self.barGraph];

    self.buffersBlock = [self.barGraph addBlockWithColor:buffersColor];
    self.cachedBlock = [self.barGraph addBlockWithColor:cachedColor];
    self.usedBlock = [self.barGraph addBlockWithColor:usedColor];
    self.freeBlock = [self.barGraph addBlockWithColor:freeColor];

    return self;
}

- (void)serverDidSet
{
    [super serverDidSet];
    
    [self refresh];
}

- (void)refresh
{
    [super refresh];
    
    if ([self.server monitoringRunning] == NO)
        return;

    HALMemoryRecorder *recorder = [self.server memoryRecorder];

    [self.buffersLabel setText:[self formattedSize:[recorder buffers] units:HALFormatSizeUnitsMB]];
    [self.cachedLabel setText:[self formattedSize:[recorder cached] units:HALFormatSizeUnitsMB]];
    [self.usedLabel setText:[self formattedSize:[recorder used] units:HALFormatSizeUnitsMB]];
    [self.freeLabel setText:[self formattedSize:[recorder free] units:HALFormatSizeUnitsMB]];

    [self.barGraph setMaxValue:[recorder total]];
    [self.buffersBlock setValue:[recorder buffers]];
    [self.cachedBlock setValue:[recorder cached]];
    [self.usedBlock setValue:[recorder used]];
    [self.freeBlock setValue:[recorder free]];

    [self.barGraph refreshBlocks];
}

@end
