//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALBarGraph.h"

@interface HALBarGraph ()

@property (assign, nonatomic) HALBarGraphType graphType;
@property (strong, nonatomic) UIView *defaultBlock;

@end

@implementation HALBarGraph
{
    CGSize padding;
}

- (id)initWithFrame:(CGRect)frame
          graphType:(HALBarGraphType)graphType
       defaultColor:(UIColor *)defaultColor
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    self.blocks = [NSMutableArray array];
    self.graphType = graphType;

    [self setBackgroundColor:[UIColor blackColor]];
    
    padding = CGSizeMake(2, 2);
    
    CGRect blockFrame = CGRectMake(padding.width - 1,
                                   padding.height - 1,
                                   CGRectGetWidth(frame) - (padding.width - 1) * 2,
                                   CGRectGetHeight(frame) - (padding.height - 1) * 2);
    
    self.defaultBlock = [[UIView alloc] initWithFrame:blockFrame];
    [self.defaultBlock setBackgroundColor:defaultColor];
    [self.layer setCornerRadius:2.0f];
    [self addSubview:self.defaultBlock];
    
    return self;
}

- (HALBarGraphBlock *)addBlockWithColor:(UIColor *)blockColor
{
    CGRect blockFrame;
    
    switch (self.graphType)
    {
        case HALBarGraphHorizontal:
            blockFrame = CGRectMake(1,
                                    1,
                                    0,
                                    CGRectGetHeight([self.defaultBlock bounds]) - 2);
            break;

        case HALBarGraphVertical:
            blockFrame = CGRectMake(1,
                                    CGRectGetHeight([self.defaultBlock bounds]) - 1,
                                    CGRectGetWidth([self.defaultBlock bounds]) - 2,
                                    0);
            break;
    }
    
    HALBarGraphBlock *block = [[HALBarGraphBlock alloc] initWithFrame:blockFrame
                                                                color:blockColor];
    
    [self.defaultBlock addSubview:block];
    [self.blocks addObject:block];
    
    return block;
}

- (UILabel *)addLabel:(NSString *)text
            textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] initWithFrame:[self bounds]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:textColor];
    [label setFont:[UIFont systemFontOfSize:9.0f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:text];
    [self addSubview:label];
    
    return label;
}

- (void)refreshBlocks
{
    CGRect bounds = [self.defaultBlock bounds];
    CGRect blockFrame;
    CGFloat totalSize;

    switch (self.graphType)
    {
        case HALBarGraphHorizontal:
            blockFrame = CGRectMake(1,
                                    1,
                                    0,
                                    CGRectGetHeight(bounds) - 2);
            totalSize = CGRectGetWidth(bounds) - 2;
            break;

        case HALBarGraphVertical:
            blockFrame = CGRectMake(1,
                                    CGRectGetHeight(bounds) - 1,
                                    CGRectGetWidth(bounds) - 2,
                                    0);
            totalSize = CGRectGetHeight(bounds) - 2;
            break;
    }

    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:0.25f];

    for (HALBarGraphBlock *block in [self blocks])
    {
        @try {
            switch (self.graphType)
            {
                case HALBarGraphHorizontal:
                    blockFrame.size.width = totalSize * ([block value] / [self maxValue]);
                    [block setFrame:blockFrame];
                    blockFrame = CGRectOffset(blockFrame, CGRectGetWidth(blockFrame), 0);
                    break;

                case HALBarGraphVertical:
                    blockFrame.size.height = totalSize * ([block value] / [self maxValue]);
                    blockFrame = CGRectOffset(blockFrame, 0, -CGRectGetHeight(blockFrame));
                    [block setFrame:blockFrame];
                    break;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%f %f %f %f", blockFrame.origin.x, blockFrame.origin.y, blockFrame.size.width, blockFrame.size.height);
        }
    }
    
    [UIView commitAnimations];
}

@end
