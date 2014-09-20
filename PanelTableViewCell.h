//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Panel.h"

@interface PanelTableViewCell : UITableViewCell

@property (strong, nonatomic) Panel *panel;

- (id)initWithPanel:(Panel *)panel
    reuseIdentifier:(NSString *)reuseIdentifier;

@end
