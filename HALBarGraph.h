//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HALBarGraphBlock.h"

@interface HALBarGraph : UIView

typedef enum
{
    HALBarGraphHorizontal,
    HALBarGraphVertical
} HALBarGraphType;

@property (assign, nonatomic) CGFloat maxValue;
@property (strong, nonatomic) NSMutableArray *blocks;

- (id)initWithFrame:(CGRect)frame
          graphType:(HALBarGraphType)graphType
       defaultColor:(UIColor *)defaultColor;

- (HALBarGraphBlock *)addBlockWithColor:(UIColor *)blockColor;

- (UILabel *)addLabel:(NSString *)text
            textColor:(UIColor *)textColor;

- (void)refreshBlocks;

@end
