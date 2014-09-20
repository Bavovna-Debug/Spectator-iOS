//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "ServerInformationPanel.h"

@interface ServerInformationPanel ()

@property (strong, nonatomic) UILabel *systemNameLabel;
@property (strong, nonatomic) UILabel *serverUptimeLabel;

@end

@implementation ServerInformationPanel

@synthesize server = _server;

- (id)initWithHeight:(CGFloat)height
{
    CGFloat fontSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        fontSize = 14.0f;
    } else {
        fontSize = 12.5f;
    }

    self = [super initWithHeight:height title:nil];
    if (self == nil)
        return nil;
    
    self.server = nil;

    CGRect contentFrame = [self contentFrame];

    UIColor *textColor = [UIColor darkTextColor];

    UIFont *font = [UIFont systemFontOfSize:fontSize];

    self.systemNameLabel = [[UILabel alloc] initWithFrame:contentFrame];
    [self.systemNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.systemNameLabel setTextColor:textColor];
    [self.systemNameLabel setFont:font];
    [self.systemNameLabel setTextAlignment:NSTextAlignmentLeft];
    [self.systemNameLabel setAdjustsFontSizeToFitWidth:YES];

    self.serverUptimeLabel = [[UILabel alloc] initWithFrame:contentFrame];
    [self.serverUptimeLabel setBackgroundColor:[UIColor clearColor]];
    [self.serverUptimeLabel setTextColor:textColor];
    [self.serverUptimeLabel setFont:font];
    [self.serverUptimeLabel setTextAlignment:NSTextAlignmentRight];

    [self addSubview:self.systemNameLabel];
    [self addSubview:self.serverUptimeLabel];
    
    return self;
}

- (void)serverDidSet
{
    [super serverDidSet];
    
    [self updateContent];
}

- (void)updateContent
{
    [self.systemNameLabel setText:[self.server serverToldSystemName]];

    NSString *uptimeText = [NSString stringWithString:NSLocalizedString(@"UPTIME_PREFIX", nil)];
    
    NSUInteger uptime = [self.server serverUptime];
    NSUInteger days = uptime / (24 * 60);
    NSUInteger hours = (uptime - (days * (24 * 60))) / 60;
    NSUInteger minutes = uptime % 60;
    
    if (uptime < 24 * 60) {
        uptimeText = [uptimeText stringByAppendingFormat:@" %02lu:%02lu",
                      (unsigned long)hours,
                      (unsigned long)minutes];
    } else {
        NSString *daysText = [NSString stringWithString:NSLocalizedString(@"UPTIME_DAYS", nil)];
        
        uptimeText = [uptimeText stringByAppendingFormat:@" %lu %@ %02lu:%02lu",
                      (unsigned long)days,
                      daysText,
                      (unsigned long)hours,
                      (unsigned long)minutes];
    }
    
    [self.serverUptimeLabel setText:uptimeText];

    CGRect systemNameFrame = [self.systemNameLabel frame];
    CGRect serverUptimeFrame = [self.serverUptimeLabel frame];
    CGSize uptimeSize = [uptimeText sizeWithFont:[self.serverUptimeLabel font]];
    CGFloat distance = 8.0f;
    
    [self.systemNameLabel setFrame:CGRectMake(CGRectGetMinX(systemNameFrame),
                                              CGRectGetMinY(systemNameFrame),
                                              CGRectGetWidth(serverUptimeFrame) - uptimeSize.width - distance,
                                              CGRectGetHeight(systemNameFrame))];
}

@end
