//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "NetworkInterfacePanel.h"

@interface NetworkInterfacePanel ()

@property (strong, nonatomic) UILabel   *interfaceNameLabel;
@property (strong, nonatomic) UILabel   *rxTotalBytesValue;
@property (strong, nonatomic) UILabel   *rxTotalFormattedValue;
@property (strong, nonatomic) UILabel   *txTotalBytesValue;
@property (strong, nonatomic) UILabel   *txTotalFormattedValue;
@property (strong, nonatomic) UILabel   *gagingSinceValue;
@property (strong, nonatomic) UILabel   *rxGagingBytesValue;
@property (strong, nonatomic) UILabel   *txGagingBytesValue;
@property (strong, nonatomic) UIButton  *gagingButton;

@end

@implementation NetworkInterfacePanel

- (id)initWithInterface:(SRVNetworkInterface *)interface
{
    self = [super initWithHeight:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 114.0f : 166.0f
                           title:nil];
    if (self == nil)
        return nil;
    
    self.interface = interface;

    CGRect contentFrame = [self contentFrame];

    CGRect interfaceNameFrame;
    CGRect totalTrafficFrame;
    CGRect gagingTrafficFrame;

    CGSize padding = [self padding];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        interfaceNameFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                        CGRectGetMinY(contentFrame),
                                        CGRectGetWidth(contentFrame),
                                        22);
        
        totalTrafficFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                       CGRectGetMinY(interfaceNameFrame) + CGRectGetHeight(interfaceNameFrame) + padding.height,
                                       (CGRectGetWidth(contentFrame) - padding.width) / 2,
                                       80);
        
        gagingTrafficFrame = CGRectOffset(totalTrafficFrame,
                                          CGRectGetWidth(totalTrafficFrame) + padding.width,
                                          0);
    } else {
        interfaceNameFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                        CGRectGetMinY(contentFrame),
                                        contentFrame.size.width,
                                        22);
        
        totalTrafficFrame = CGRectMake(CGRectGetMinX(contentFrame),
                                       CGRectGetMinY(interfaceNameFrame) + CGRectGetHeight(interfaceNameFrame) + padding.height,
                                       CGRectGetWidth(contentFrame),
                                       64);

        gagingTrafficFrame = CGRectOffset(totalTrafficFrame,
                                          0,
                                          CGRectGetHeight(totalTrafficFrame) + padding.height);
    }

    CGFloat interfaceNameFontSize = 20.0f;
    CGFloat dataFontSize = 12.5f;
    
    UIFont *interfaceNameFont = [UIFont systemFontOfSize:interfaceNameFontSize];    
    UIFont *dataLabelFont = [UIFont systemFontOfSize:dataFontSize];
    UIFont *dataValueFont = [UIFont boldSystemFontOfSize:dataFontSize];

    NSString *totalTrafficText = [NSString stringWithString:NSLocalizedString(@"NETWORK_TRAFFIC_TOTAL", nil)];
    NSString *gagingTrafficText = [NSString stringWithString:NSLocalizedString(@"NETWORK_TRAFFIC_GAGING", nil)];
    NSString *rxTrafficText = [NSString stringWithString:NSLocalizedString(@"NETWORK_TRAFFIC_RX", nil)];
    NSString *txTrafficText = [NSString stringWithString:NSLocalizedString(@"NETWORK_TRAFFIC_TX", nil)];
    
    UIColor *interfaceNameColor = [UIColor blackColor];
    UIColor *dataLabelColor = [UIColor darkGrayColor];
    UIColor *dataValueColor = [UIColor darkTextColor];
    UIColor *dataFormattedColor = [UIColor darkGrayColor];

    CGSize gagingTrafficLabelSize = [gagingTrafficText sizeWithFont:dataLabelFont];
    CGSize rxLabelSize = [rxTrafficText sizeWithFont:dataLabelFont];
    CGSize txLabelSize = [txTrafficText sizeWithFont:dataLabelFont];
    
    CGFloat labelWidth = gagingTrafficLabelSize.width;
    if (rxLabelSize.width > labelWidth)
        labelWidth = rxLabelSize.width;
    if (txLabelSize.width > labelWidth)
        labelWidth = txLabelSize.width;
    labelWidth += padding.width;
    
    self.interfaceNameLabel = [[UILabel alloc] initWithFrame:interfaceNameFrame];
    [self.interfaceNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.interfaceNameLabel setTextColor:interfaceNameColor];
    [self.interfaceNameLabel setFont:interfaceNameFont];
    [self addSubview:self.interfaceNameLabel];

    UIView *totalTrafficView = [[UIView alloc] initWithFrame:totalTrafficFrame];
    UIView *gagingTrafficView = [[UIView alloc] initWithFrame:gagingTrafficFrame];

    [totalTrafficView setBackgroundColor:[UIColor colorWithRed:1.000f green:0.800f blue:0.400f alpha:1.0f]];
    [gagingTrafficView setBackgroundColor:[UIColor colorWithRed:0.400f green:0.800f blue:1.000f alpha:1.0f]];

    [totalTrafficView.layer setCornerRadius:2.0f];
    [gagingTrafficView.layer setCornerRadius:2.0f];

    [self addSubview:totalTrafficView];
    [self addSubview:gagingTrafficView];
    
    CGRect labelRect;
    CGRect valueRect;

    labelRect = CGRectMake(padding.width,
                           padding.height,
                           CGRectGetWidth(totalTrafficFrame) - 2 * padding.width,
                           CGRectGetHeight(totalTrafficFrame) - 2 * padding.height);
    labelRect.size.height /= 3;

    UILabel *totalTrafficLabel = [[UILabel alloc] initWithFrame:labelRect];
    [totalTrafficLabel setBackgroundColor:[UIColor clearColor]];
    [totalTrafficLabel setTextColor:dataLabelColor];
    [totalTrafficLabel setFont:dataLabelFont];
    [totalTrafficLabel setText:totalTrafficText];
    [totalTrafficView addSubview:totalTrafficLabel];

    valueRect = labelRect;
    labelRect.size.width = labelWidth;
    valueRect.origin.x += labelWidth;
    valueRect.size.width -= labelWidth;
    
    UILabel *gagingTrafficLabel = [[UILabel alloc] initWithFrame:labelRect];
    [gagingTrafficLabel setBackgroundColor:[UIColor clearColor]];
    [gagingTrafficLabel setTextColor:dataLabelColor];
    [gagingTrafficLabel setFont:dataLabelFont];
    [gagingTrafficLabel setText:gagingTrafficText];
    [gagingTrafficView addSubview:gagingTrafficLabel];

    self.gagingSinceValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.gagingSinceValue setBackgroundColor:[UIColor clearColor]];
    [self.gagingSinceValue setTextColor:dataValueColor];
    [self.gagingSinceValue setFont:dataValueFont];
    [gagingTrafficView addSubview:self.gagingSinceValue];
    
    labelRect = CGRectOffset(labelRect, 0, CGRectGetHeight(labelRect));
    valueRect = CGRectOffset(valueRect, 0, CGRectGetHeight(valueRect));
    
    UILabel *rxTotalBytesLabel = [[UILabel alloc] initWithFrame:labelRect];
    [rxTotalBytesLabel setBackgroundColor:[UIColor clearColor]];
    [rxTotalBytesLabel setTextColor:dataLabelColor];
    [rxTotalBytesLabel setFont:dataLabelFont];
    [rxTotalBytesLabel setText:rxTrafficText];
    [totalTrafficView addSubview:rxTotalBytesLabel];

    UILabel *rxGagingBytesLabel = [[UILabel alloc] initWithFrame:labelRect];
    [rxGagingBytesLabel setBackgroundColor:[UIColor clearColor]];
    [rxGagingBytesLabel setTextColor:dataLabelColor];
    [rxGagingBytesLabel setFont:dataLabelFont];
    [rxGagingBytesLabel setText:rxTrafficText];
    [gagingTrafficView addSubview:rxGagingBytesLabel];

    self.rxTotalBytesValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.rxTotalBytesValue setBackgroundColor:[UIColor clearColor]];
    [self.rxTotalBytesValue setTextColor:dataValueColor];
    [self.rxTotalBytesValue setFont:dataValueFont];
    [totalTrafficView addSubview:self.rxTotalBytesValue];

    self.rxTotalFormattedValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.rxTotalFormattedValue setBackgroundColor:[UIColor clearColor]];
    [self.rxTotalFormattedValue setTextColor:dataFormattedColor];
    [self.rxTotalFormattedValue setFont:dataValueFont];
    [self.rxTotalFormattedValue setTextAlignment:NSTextAlignmentRight];
    [totalTrafficView addSubview:self.rxTotalFormattedValue];

    self.rxGagingBytesValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.rxGagingBytesValue setBackgroundColor:[UIColor clearColor]];
    [self.rxGagingBytesValue setTextColor:dataValueColor];
    [self.rxGagingBytesValue setFont:dataValueFont];
    [gagingTrafficView addSubview:self.rxGagingBytesValue];

    labelRect = CGRectOffset(labelRect, 0, CGRectGetHeight(labelRect));
    valueRect = CGRectOffset(valueRect, 0, CGRectGetHeight(valueRect));
    
    UILabel *txTotalBytesLabel = [[UILabel alloc] initWithFrame:labelRect];
    [txTotalBytesLabel setBackgroundColor:[UIColor clearColor]];
    [txTotalBytesLabel setTextColor:dataLabelColor];
    [txTotalBytesLabel setFont:dataLabelFont];
    [txTotalBytesLabel setText:txTrafficText];
    [totalTrafficView addSubview:txTotalBytesLabel];
    
    UILabel *txGagingBytesLabel = [[UILabel alloc] initWithFrame:labelRect];
    [txGagingBytesLabel setBackgroundColor:[UIColor clearColor]];
    [txGagingBytesLabel setTextColor:dataLabelColor];
    [txGagingBytesLabel setFont:dataLabelFont];
    [txGagingBytesLabel setText:txTrafficText];
    [gagingTrafficView addSubview:txGagingBytesLabel];
    
    self.txTotalBytesValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.txTotalBytesValue setBackgroundColor:[UIColor clearColor]];
    [self.txTotalBytesValue setTextColor:dataValueColor];
    [self.txTotalBytesValue setFont:dataValueFont];
    [totalTrafficView addSubview:self.txTotalBytesValue];

    self.txTotalFormattedValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.txTotalFormattedValue setBackgroundColor:[UIColor clearColor]];
    [self.txTotalFormattedValue setTextColor:dataFormattedColor];
    [self.txTotalFormattedValue setFont:dataValueFont];
    [self.txTotalFormattedValue setTextAlignment:NSTextAlignmentRight];
    [totalTrafficView addSubview:self.txTotalFormattedValue];
    
    self.txGagingBytesValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.txGagingBytesValue setBackgroundColor:[UIColor clearColor]];
    [self.txGagingBytesValue setTextColor:dataValueColor];
    [self.txGagingBytesValue setFont:dataValueFont];
    [gagingTrafficView addSubview:self.txGagingBytesValue];

    CGRect gagingButtonFrame = CGRectMake(0, 0, CGRectGetWidth(gagingTrafficFrame), CGRectGetHeight(gagingTrafficFrame));
    gagingButtonFrame = CGRectInset(gagingButtonFrame, padding.width, padding.height);
    gagingButtonFrame.origin.x += gagingButtonFrame.size.width - gagingButtonFrame.size.height;
    gagingButtonFrame.size.width = gagingButtonFrame.size.height;

    self.gagingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.gagingButton setBackgroundColor:[UIColor clearColor]];
    [self.gagingButton setFrame:gagingButtonFrame];
    [self.gagingButton setImage:[UIImage imageNamed:@"Network-StopGaging"]
                       forState:UIControlStateNormal];
    [gagingTrafficView addSubview:self.gagingButton];
    
    [self refresh];

    [self.gagingButton addTarget:self
                          action:@selector(didTouchGagingButton)
                forControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

- (void)refresh
{
    [self.interfaceNameLabel setText:[self.interface interfaceName]];
    [self.rxTotalBytesValue setText:[NSString stringWithFormat:@"%lu", (unsigned long)[self.interface rxBytesTotal]]];
    [self.txTotalBytesValue setText:[NSString stringWithFormat:@"%lu", (unsigned long)[self.interface txBytesTotal]]];

    [self.rxTotalFormattedValue setText:[self formattedSize:[self.interface rxBytesTotal]]];
    [self.txTotalFormattedValue setText:[self formattedSize:[self.interface txBytesTotal]]];
    
    [self.rxGagingBytesValue setText:[NSString stringWithFormat:@"%lu", (unsigned long)[self.interface rxBytesGaging]]];
    [self.txGagingBytesValue setText:[NSString stringWithFormat:@"%lu", (unsigned long)[self.interface txBytesGaging]]];
}

- (void)refreshStopwatch
{
    NSTimeInterval timeRange;
    if ([self.interface gaging] == YES) {
        timeRange = [[NSDate date] timeIntervalSinceDate:[self.interface gagingBegin]];
    } else {
        timeRange = [[self.interface gagingEnd] timeIntervalSinceDate:[self.interface gagingBegin]];
    }
    
    NSInteger seconds = (NSInteger)timeRange % 60;
    NSInteger minutes = ((NSInteger)timeRange / 60) % 60;
    NSInteger hours = ((NSInteger)timeRange / 3600);
    NSString *gagingSinceText = [NSString stringWithFormat:@"%0ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];

    [self.gagingSinceValue setText:gagingSinceText];
}

- (void)didTouchGagingButton
{
    if ([self.interface gaging] == YES) {
        [self.interface setGaging:NO];

        [self.gagingButton setImage:[UIImage imageNamed:@"Network-StartGaging"]
                           forState:UIControlStateNormal];
        
        [self.gagingSinceValue setTextColor:[UIColor redColor]];
        [self.rxGagingBytesValue setTextColor:[UIColor redColor]];
        [self.txGagingBytesValue setTextColor:[UIColor redColor]];
    } else {
        [self.interface setGaging:YES];

        [self.gagingButton setImage:[UIImage imageNamed:@"Network-StopGaging"]
                           forState:UIControlStateNormal];
        
        [self.gagingSinceValue setTextColor:[UIColor darkTextColor]];
        [self.rxGagingBytesValue setTextColor:[UIColor darkTextColor]];
        [self.txGagingBytesValue setTextColor:[UIColor darkTextColor]];
        
        [UIView commitAnimations];
    }

    [self refresh];
}

- (NSString *)formattedSize:(CGFloat)size
{
    const double KB = 1024;
    const double MB = 1024 * 1024;
    const double GB = 1024 * 1024 * 1024;
    
    double result;
    NSString *units;
    
    if (size < 10 * KB) {
        result = size;
        units = [NSString stringWithString:NSLocalizedString(@"BYTES", nil)];
        return [NSString stringWithFormat:@"%0.0f %@", result, units];
    } else if (size < MB) {
        result = size / KB;
        units = [NSString stringWithString:NSLocalizedString(@"KB", nil)];
        return [NSString stringWithFormat:@"%0.1f %@", result, units];
    } else if (size < GB) {
        result = size / MB;
        units = [NSString stringWithString:NSLocalizedString(@"MB", nil)];
        return [NSString stringWithFormat:@"%0.1f %@", result, units];
    } else {
        size /= GB;
        if (size < 2048) {
            result = size;
            units = [NSString stringWithString:NSLocalizedString(@"GB", nil)];
        } else {
            result = size / 1024;
            units = [NSString stringWithString:NSLocalizedString(@"TB", nil)];
        }
        return [NSString stringWithFormat:@"%0.2f %@", result, units];
    }
}

@end
