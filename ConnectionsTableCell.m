//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "ConnectionsTableCell.h"
#import "Server.h"

#import "SRVConnectionRecord.h"

@interface ConnectionsTableCell ()

@property (strong, nonatomic) UIImageView  *appearanceSymbol;
@property (strong, nonatomic) UILabel      *localPortLabel;
@property (strong, nonatomic) UILabel      *hostNameLabel;
@property (strong, nonatomic) UILabel      *timestampLabel;

@end

@implementation ConnectionsTableCell
{
    Boolean expanded;
}

- (id)initWithConnection:(SRVConnectionRecord *)connection
{
    NSString *cellIdentifier = nil;    
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
    if (self == nil)
        return nil;
    
    [self setBackgroundColor:[UIColor clearColor]];

    self.connection = connection;
 
    expanded = NO;

    CGSize cellSize;
    
    CGFloat localPortFontSize;
    CGFloat ipAddressFontSize;
    CGFloat timestampFontSize;

    CGRect appearanceRect;
    CGRect localPortRect;
    CGRect hostNameRect;
    CGRect timestampRect;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        localPortFontSize = 16.0f;
        ipAddressFontSize = 14.0f;
        timestampFontSize = 14.0f;
    } else {
        localPortFontSize = 14.0f;
        ipAddressFontSize = 12.5f;
        timestampFontSize = 12.5f;
        
        [self setAccessoryType:UITableViewCellAccessoryDetailButton];
    }

    UIFont *localPortFont = [UIFont systemFontOfSize:localPortFontSize];
    UIFont *ipAddressFont = [UIFont systemFontOfSize:ipAddressFontSize];
    UIFont *timestampFont = [UIFont systemFontOfSize:timestampFontSize];
    
    CGSize localPortSize = [@"00000" sizeWithFont:localPortFont];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cellSize = CGSizeMake(768.0f, [self cellHeight]);
        CGSize margin = CGSizeMake(8, 0);

        localPortRect = CGRectMake(margin.width,
                                   0,
                                   localPortSize.width,
                                   cellSize.height);
        
        appearanceRect = CGRectMake(localPortRect.origin.x + localPortRect.size.width,
                                    0,
                                    cellSize.height,
                                    cellSize.height);
        
        hostNameRect = CGRectMake(appearanceRect.origin.x + appearanceRect.size.width,
                                  0,
                                  cellSize.width - (appearanceRect.origin.x + appearanceRect.size.width) - cellSize.height,
                                  cellSize.height);
        
        timestampRect = hostNameRect;
    } else {
        cellSize = CGSizeMake(320.0f, [self cellHeight]);
        CGSize margin = CGSizeMake(4, 0);

        localPortRect = CGRectMake(margin.width,
                                   0,
                                   localPortSize.width,
                                   cellSize.height);
        
        appearanceRect = CGRectMake(localPortRect.origin.x + localPortRect.size.width,
                                    0,
                                    cellSize.height,
                                    cellSize.height);
        
        hostNameRect = CGRectMake(appearanceRect.origin.x + appearanceRect.size.width,
                                  0,
                                  cellSize.width - (localPortRect.origin.x + localPortRect.size.width + 8 + cellSize.height),
                                  cellSize.height);
        
        timestampRect = CGRectOffset(hostNameRect, 0, cellSize.height);
    }

    NSString *ipAddress = [connection ipAddress];
    UInt16 remotePort = [connection remotePort];
    UInt16 localPort = [connection localPort];
    NSString *timestampText = [NSDateFormatter localizedStringFromDate:[connection openedStamp]
                                                             dateStyle:NSDateFormatterMediumStyle
                                                             timeStyle:NSDateFormatterMediumStyle];

#ifdef SCREENSHOTING
    if ([ipAddress compare:@"78.47.11.62"] == NSOrderedSame)
        ipAddress = @"193.0.4.3";
    if ([ipAddress compare:@"134.3.135.100"] == NSOrderedSame)
        ipAddress = @"192.168.1.12";
    if ([ipAddress compare:@"::ffff:134.3.135.100"] == NSOrderedSame)
        ipAddress = @"192.168.1.18";
    if (localPort == 9090)
        localPort = 48100;
#endif

    self.localPortLabel = [[UILabel alloc] initWithFrame:localPortRect];
    [self.localPortLabel setBackgroundColor:[UIColor clearColor]];
    [self.localPortLabel setTextAlignment:NSTextAlignmentRight];
    [self.localPortLabel setTextColor:[UIColor colorWithRed:0.357f green:0.149f blue:0.835f alpha:1.0f]];
    [self.localPortLabel setFont:localPortFont];
    [self.localPortLabel setText:[NSString stringWithFormat:@"%d", localPort]];
    [self.contentView addSubview:self.localPortLabel];
    
    self.hostNameLabel = [[UILabel alloc] initWithFrame:hostNameRect];
    [self.hostNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.hostNameLabel setTextColor:[UIColor darkTextColor]];
    [self.hostNameLabel setFont:ipAddressFont];
    [self.hostNameLabel setText:[NSString stringWithFormat:@"%@ (%d)", ipAddress, remotePort]];
    [self.contentView addSubview:self.hostNameLabel];
 
    self.timestampLabel = [[UILabel alloc] initWithFrame:timestampRect];
    [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
    [self.timestampLabel setTextColor:[UIColor darkGrayColor]];
    [self.timestampLabel setFont:timestampFont];
    [self.timestampLabel setText:timestampText];
    [self.contentView addSubview:self.timestampLabel];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.timestampLabel setTextAlignment:NSTextAlignmentRight];
    } else {
        [self.timestampLabel setHidden:YES];
    }

    self.appearanceSymbol = [[UIImageView alloc] initWithFrame:appearanceRect];
    [self.contentView addSubview:self.appearanceSymbol];
    
    return self;
}

- (CGFloat)cellHeight
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 28.0f;
    } else {
        return (expanded == NO) ? 24.0f : 48.0f;
    }
}

- (void)accessoryButtonTapped
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        expanded = !expanded;
        if (expanded) {
            [self.timestampLabel setHidden:NO];
        } else {
            [self.timestampLabel setHidden:YES];
        }
    }
}

- (void)animateAppearance
{
    [self setBackgroundColor:[UIColor colorWithRed:0.545f green:0.937f blue:1.000f alpha:1.0f]];
    
    [self.appearanceSymbol setImage:[UIImage imageNamed:@"InetConnectionAppeared"]];
    [self.appearanceSymbol setAlpha:1.0f];
    
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:2.0f];

    [self setBackgroundColor:[UIColor whiteColor]];
    
    [UIView commitAnimations];

    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:10.0f];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.appearanceSymbol setAlpha:0.0f];
    
    [UIView commitAnimations];
}

- (void)animateDisappearance
{
    [self.appearanceSymbol setImage:[UIImage imageNamed:@"InetConnectionDisappeared"]];
    [self.appearanceSymbol setAlpha:0.0f];
 
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:0.4f];
    
    [self.appearanceSymbol setAlpha:1.0f];
    
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:2.0f];
    
    [self setBackgroundColor:[UIColor colorWithRed:1.000f green:0.471f blue:0.400f alpha:1.0f]];

    [UIView commitAnimations];
}

@end

