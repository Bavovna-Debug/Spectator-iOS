//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALPanel.h"
#import "HALPanelTableView.h"
#import "HALPanelTableViewCell.h"

@implementation HALPanelTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame
                          style:UITableViewStylePlain];
    if (self == nil)
        return nil;

    [self setAllowsSelection:NO];
    [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    UIView *background = [[UIView alloc] init];
    [background setBackgroundColor:[UIColor colorWithRed:1.000f green:0.929f blue:0.831f alpha:1.0f]];
    [self setBackgroundView:background];

    return self;
}

- (CGSize)margin
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(8.0f, 4.0f);
    } else {
        return CGSizeMake(4.0f, 2.0f);
    }
}

@end
