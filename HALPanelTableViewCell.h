//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HALPanel.h"

@interface HALPanelTableViewCell : UITableViewCell

@property (strong, nonatomic) HALPanel *panel;

- (id)initWithPanel:(HALPanel *)panel
    reuseIdentifier:(NSString *)reuseIdentifier;

@end
