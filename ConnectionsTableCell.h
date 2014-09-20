//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SRVConnectionRecord.h"

@interface ConnectionsTableCell : UITableViewCell

@property (strong, nonatomic) SRVConnectionRecord *connection;

- (id)initWithConnection:(SRVConnectionRecord *)connection;

- (CGFloat)cellHeight;

- (void)accessoryButtonTapped;

- (void)animateAppearance;

- (void)animateDisappearance;

@end
