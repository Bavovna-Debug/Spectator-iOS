//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALBarGraphBlock.h"

@implementation HALBarGraphBlock

- (id)initWithFrame:(CGRect)frame
              color:(UIColor *)color
              alpha:(CGFloat)alpha
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;

    self.value = 0.0f;

    [self setBackgroundColor:color];
    [self setAlpha:alpha];

    return self;
}

@end
