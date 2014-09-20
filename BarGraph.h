//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BarGraphBlock.h"

@interface BarGraph : UIView

typedef enum
{
    BarGraphHorizontal,
    BarGraphVertical
} BarGraphType;

@property (assign, nonatomic) CGFloat maxValue;
@property (strong, nonatomic) NSMutableArray *blocks;

- (id)initWithFrame:(CGRect)frame
          graphType:(BarGraphType)graphType;

- (BarGraphBlock *)addBlockWithColor:(UIColor *)blockColor;

- (UILabel *)addLabel:(NSString *)text
            textColor:(UIColor *)textColor;

- (void)refreshBlocks;

@end
