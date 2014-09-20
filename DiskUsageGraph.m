//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "DiskUsageGraph.h"

@implementation DiskUsageGraph

- (id)initWithFrame:(CGRect)frame
              mount:(SRVMountRecord *)mount
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;

    self.mount = mount;
    
    return self;
}

- (void)updateGraph
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat procentUsed;
    CGFloat procentAvailable;
    if ([self.mount totalBlocks] > 0) {
        procentUsed = (CGFloat)([self.mount totalBlocks] - [self.mount freeBlocks]) / (CGFloat)[self.mount totalBlocks];
        procentAvailable = (CGFloat)[self.mount availableBlocks] / (CGFloat)[self.mount totalBlocks];
        procentUsed *= 100.0f;
        procentAvailable *= 100.0f;
    } else {
        procentUsed = 0.0f;
        procentAvailable = 0.0f;
    }

    UIImage *backgroundImage = [UIImage imageNamed:@"CircleGraphBackground"];
    UIImage *layerImage = [UIImage imageNamed:@"CircleGraphLayer"];

    CGPoint center = CGPointMake(rect.size.width / 2,
                                 rect.size.height / 2);
    
    CGFloat radius = 50.0f;

    CGFloat startAngle = M_PI * 1.5f;
    CGFloat endAngle = startAngle + M_PI / radius * procentUsed;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);

    [backgroundImage drawInRect:rect];

    CGContextMoveToPoint(context, center.x, center.y);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.5f blue:0.0f alpha:0.6f].CGColor);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextFlush(context);
    CGContextFillPath(context);

    startAngle = endAngle;
    endAngle = startAngle + M_PI / radius * procentAvailable;

    CGContextMoveToPoint(context, center.x, center.y);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.6f].CGColor);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextFlush(context);
    CGContextFillPath(context);
    
    startAngle = endAngle;
    endAngle = startAngle + M_PI / radius * (100.0f - procentUsed - procentAvailable);

    CGContextMoveToPoint(context, center.x, center.y);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.6f].CGColor);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextFlush(context);
    CGContextFillPath(context);

    [layerImage drawInRect:rect];
    
    if ([self.mount totalBlocks] > 0) {
        NSString *procentText = [NSString stringWithFormat:@"%0.2f%%", procentUsed];

        UIFont *font = [UIFont systemFontOfSize:18];
        
        CGSize stringSize = [procentText sizeWithFont:font];
        CGRect stringRect = CGRectMake(center.x - stringSize.width / 2,
                                       center.y - stringSize.height / 2,
                                       stringSize.width,
                                       stringSize.height);

        [[UIColor whiteColor] set];
        [procentText drawInRect:CGRectOffset(stringRect, -1, -1) withFont:font];
        
        [[UIColor lightGrayColor] set];
        [procentText drawInRect:CGRectOffset(stringRect, 1, 1) withFont:font];

        [[UIColor darkGrayColor] set];
        [procentText drawInRect:stringRect withFont:font];
    }
}

@end
