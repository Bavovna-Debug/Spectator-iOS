//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "BarGraph.h"
#import "BarGraphBlock.h"
#import "SwapPanel.h"

#import "SRVSwapRecorder.h"

@interface SwapPanel ()

@property (strong, nonatomic) BarGraph       *barGraph;
@property (strong, nonatomic) UILabel        *usedLabel;
@property (strong, nonatomic) UILabel        *freeLabel;
@property (strong, nonatomic) BarGraphBlock  *usedBlock;
@property (strong, nonatomic) BarGraphBlock  *freeBlock;

@end

@implementation SwapPanel

- (id)initWithHeight:(CGFloat)height
               title:(NSString *)title
{
    self = [super initWithHeight:height
                           title:title];
    if (self == nil)
        return nil;

    UIColor *usedColor = [UIColor colorWithRed:1.000f green:0.200f blue:0.200f alpha:1.0f];
    UIColor *freeColor = [UIColor colorWithRed:0.250f green:0.800f blue:0.000f alpha:1.0f];

    NSString *usedText = [NSString stringWithString:NSLocalizedString(@"SWAP_USED", nil)];
    NSString *freeText = [NSString stringWithString:NSLocalizedString(@"SWAP_FREE", nil)];
    
    CGSize padding = [self padding];

    CGRect usedFrame;
    CGRect freeFrame;
    CGRect chartFrame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect contentFrame = [self contentFrame];
        CGFloat percentDisplayHeight = 22.0f;
        
        usedFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                  CGRectGetMinY(contentFrame),
                                  (CGRectGetWidth(contentFrame) - padding.width * 3) / 4,
                                  percentDisplayHeight);
        
        freeFrame = CGRectOffset(usedFrame, CGRectGetWidth(usedFrame) + padding.width, 0);
        
        chartFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                CGRectGetMaxY(freeFrame) + padding.height,
                                CGRectGetWidth(contentFrame),
                                CGRectGetMaxY(contentFrame) - (CGRectGetMaxY(freeFrame) + padding.height));
    } else {
        CGRect contentFrame = [self contentFrame];
        CGFloat percentDisplayHeight = 18.0f;
        
        usedFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                  CGRectGetMinY(contentFrame),
                                  CGRectGetWidth(contentFrame) / 2 - padding.width,
                                  percentDisplayHeight);
        
        freeFrame = CGRectOffset(usedFrame, CGRectGetWidth(contentFrame) / 2 + padding.width, 0);

        chartFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                CGRectGetMaxY(freeFrame) + padding.height,
                                CGRectGetWidth(contentFrame),
                                CGRectGetMaxY(contentFrame) - (CGRectGetMaxY(freeFrame) + padding.height));
        
    }

    self.usedLabel = [self addPercentDisplayWithFrame:usedFrame
                                                color:usedColor
                                                 text:usedText];

    self.freeLabel = [self addPercentDisplayWithFrame:freeFrame
                                                color:freeColor
                                                 text:freeText];

    self.barGraph = [[BarGraph alloc] initWithFrame:chartFrame
                                          graphType:BarGraphHorizontal];
    [self addSubview:self.barGraph];

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
    
    SRVSwapRecorder *recorder = [self.server swapRecorder];

    UInt64 used = [recorder used];
    UInt64 free = [recorder total] - used;

    [self.usedLabel setText:[self formattedSize:used units:FormatSizeUnitsMB]];
    [self.freeLabel setText:[self formattedSize:free units:FormatSizeUnitsMB]];
    
    [self.barGraph setMaxValue:[recorder total]];
    [self.usedBlock setValue:used];
    [self.freeBlock setValue:free];
    
    [self.barGraph refreshBlocks];
}

@end
