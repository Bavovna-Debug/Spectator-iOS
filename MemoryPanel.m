//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "BarGraph.h"
#import "BarGraphBlock.h"
#import "MemoryPanel.h"

#import "SRVMemoryRecorder.h"

@interface MemoryPanel ()

@property (strong, nonatomic) BarGraph       *barGraph;
@property (strong, nonatomic) UILabel        *buffersLabel;
@property (strong, nonatomic) UILabel        *cachedLabel;
@property (strong, nonatomic) UILabel        *usedLabel;
@property (strong, nonatomic) UILabel        *freeLabel;
@property (strong, nonatomic) BarGraphBlock  *buffersBlock;
@property (strong, nonatomic) BarGraphBlock  *cachedBlock;
@property (strong, nonatomic) BarGraphBlock  *usedBlock;
@property (strong, nonatomic) BarGraphBlock  *freeBlock;

@end

@implementation MemoryPanel

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

    self.barGraph = [[BarGraph alloc] initWithFrame:chartFrame
                                          graphType:BarGraphHorizontal];
    [self addSubview:self.barGraph];

    self.buffersBlock  = [self.barGraph addBlockWithColor:buffersColor];
    self.cachedBlock   = [self.barGraph addBlockWithColor:cachedColor];
    self.usedBlock     = [self.barGraph addBlockWithColor:usedColor];
    self.freeBlock     = [self.barGraph addBlockWithColor:freeColor];

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

    SRVMemoryRecorder *recorder = [self.server memoryRecorder];

    [self.buffersLabel setText:[self formattedSize:[recorder buffers] units:FormatSizeUnitsMB]];
    [self.cachedLabel setText:[self formattedSize:[recorder cached] units:FormatSizeUnitsMB]];
    [self.usedLabel setText:[self formattedSize:[recorder used] units:FormatSizeUnitsMB]];
    [self.freeLabel setText:[self formattedSize:[recorder free] units:FormatSizeUnitsMB]];

    [self.barGraph setMaxValue:[recorder total]];
    [self.buffersBlock setValue:[recorder buffers]];
    [self.cachedBlock setValue:[recorder cached]];
    [self.usedBlock setValue:[recorder used]];
    [self.freeBlock setValue:[recorder free]];

    [self.barGraph refreshBlocks];
}

@end
