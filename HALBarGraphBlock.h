//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HALBarGraphBlock : UIView

@property (assign, nonatomic) CGFloat value;

- (id)initWithFrame:(CGRect)frame
              color:(UIColor *)color;

@end
