//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarGraphBlock : UIView

@property (assign, nonatomic) CGFloat value;

- (id)initWithFrame:(CGRect)frame
              color:(UIColor *)color
              alpha:(CGFloat)alpha;

@end
