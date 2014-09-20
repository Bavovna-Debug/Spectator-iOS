//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "BarGraph.h"

@interface BarGraph ()

@property (assign, nonatomic) BarGraphType  graphType;
@property (assign, nonatomic) CGRect        graphFrame;
@property (strong, nonatomic) UIView        *defaultBlock;

@end

@implementation BarGraph

- (id)initWithFrame:(CGRect)frame
          graphType:(BarGraphType)graphType
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    self.blocks = [NSMutableArray array];
    self.graphType = graphType;

    switch (self.graphType)
    {
        case BarGraphHorizontal:
            self.graphFrame = CGRectInset([self bounds], 4.0f, 4.5f);
            break;

        case BarGraphVertical:
            self.graphFrame = CGRectInset([self bounds], 1, 1);
            break;
    }

    switch (self.graphType)
    {
        case BarGraphHorizontal:
        {
            [self setBackgroundColor:[UIColor clearColor]];

            UIImage *backgroundImage;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                backgroundImage = [UIImage imageNamed:@"BarGraphPanelPad"];
            } else {
                backgroundImage = [UIImage imageNamed:@"BarGraphPanelPod"];
            }
            UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];

            self.defaultBlock = [[UIView alloc] initWithFrame:self.graphFrame];
            [self.defaultBlock setBackgroundColor:[UIColor clearColor]];
            [self.defaultBlock.layer setCornerRadius:5.0f];

            [self addSubview:backgroundView];
            [self addSubview:self.defaultBlock];

            break;
        }

        case BarGraphVertical:
            [self setBackgroundColor:[UIColor blackColor]];

            self.defaultBlock = [[UIView alloc] initWithFrame:self.graphFrame];
            [self.defaultBlock setBackgroundColor:[UIColor blackColor]];

            [self addSubview:self.defaultBlock];

            [self.layer setCornerRadius:2.0f];

            break;
    }

    return self;
}

- (BarGraphBlock *)addBlockWithColor:(UIColor *)blockColor
{
    BarGraphBlock *block;

    switch (self.graphType)
    {
        case BarGraphHorizontal:
        {
            CGRect blockFrame = CGRectMake(0,
                                           0,
                                           0,
                                           CGRectGetHeight(self.graphFrame));
            block = [[BarGraphBlock alloc] initWithFrame:blockFrame
                                                   color:blockColor
                                                   alpha:0.75f];
            break;
        }

        case BarGraphVertical:
        {
            CGRect blockFrame = CGRectMake(1,
                                           CGRectGetHeight(self.graphFrame) - 1,
                                           CGRectGetWidth(self.graphFrame) - 2,
                                           0);

            block = [[BarGraphBlock alloc] initWithFrame:blockFrame
                                                   color:blockColor
                                                   alpha:1.0f];
            break;
        }
    }

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
    CGRect blockFrame;
    CGFloat totalSize;

    switch (self.graphType)
    {
        case BarGraphHorizontal:
            blockFrame = CGRectMake(1,
                                    1,
                                    0,
                                    CGRectGetHeight(self.graphFrame) - 2);
            totalSize = CGRectGetWidth(self.graphFrame) - 2;
            break;

        case BarGraphVertical:
            blockFrame = CGRectMake(1,
                                    CGRectGetHeight(self.graphFrame) - 1,
                                    CGRectGetWidth(self.graphFrame) - 2,
                                    0);
            totalSize = CGRectGetHeight(self.graphFrame) - 2;
            break;
    }

    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:0.25f];

    for (BarGraphBlock *block in [self blocks])
    {
        @try {
            switch (self.graphType)
            {
                case BarGraphHorizontal:
                    blockFrame.size.width = totalSize * ([block value] / [self maxValue]);
                    [block setFrame:blockFrame];
                    blockFrame = CGRectOffset(blockFrame, CGRectGetWidth(blockFrame), 0);
                    break;

                case BarGraphVertical:
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
