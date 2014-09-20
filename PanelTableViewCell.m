//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "PanelTableViewCell.h"

@implementation PanelTableViewCell

- (id)initWithPanel:(Panel *)panel
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
    if (self == nil)
        return nil;

    self.panel = panel;
    
    [self setBackgroundColor:[UIColor clearColor]];

    [self.contentView addSubview:panel];

    [self.panel setHidden:NO];

    return self;
}

@end
