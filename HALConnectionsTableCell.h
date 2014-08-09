//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HALConnectionRecord.h"

@interface HALConnectionsTableCell : UITableViewCell

@property (strong, nonatomic) HALConnectionRecord *record;

- (id)initWithConnection:(HALConnectionRecord *)record;

- (CGFloat)cellHeight;

- (void)accessoryButtonTapped;

- (void)animateAppearance;

- (void)animateDisappearance;

@end
