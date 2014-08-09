//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HALMount.h"

@interface HALDiskUsageGraph : UIView

@property (weak, nonatomic) HALMount *mount;

- (id)initWithFrame:(CGRect)frame
              mount:(HALMount *)mount;

- (void)updateGraph;

@end
