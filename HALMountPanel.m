//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALDiskUsageGraph.h"
#import "HALMountPanel.h"

@interface HALMountPanel ()

@property (strong, nonatomic) UILabel *mountPointLabel;
@property (strong, nonatomic) UILabel *deviceNameLabel;
@property (strong, nonatomic) UILabel *totalLabel;
@property (strong, nonatomic) UILabel *totalValue;
@property (strong, nonatomic) UILabel *usedLabel;
@property (strong, nonatomic) UILabel *usedValue;
@property (strong, nonatomic) UILabel *availableLabel;
@property (strong, nonatomic) UILabel *availableValue;
@property (strong, nonatomic) UILabel *reservedLabel;
@property (strong, nonatomic) UILabel *reservedValue;
@property (strong, nonatomic) HALDiskUsageGraph *diskUsageGraph;

@end

@implementation HALMountPanel

@synthesize showBytes = _showBytes;

- (id)initWithMount:(HALMount *)mount
{
    CGFloat graphSize = 128.0f;

    self = [super initWithHeight:graphSize - self.padding.height * 2
                           title:nil];
    if (self == nil)
        return nil;

    self.mount = mount;

    CGRect contentFrame = [self contentFrame];

    CGSize padding = [self padding];
    
    CGFloat mountPointFontSize;
    CGFloat deviceNameFontSize;
    CGFloat dataFontSize;
    
    mountPointFontSize = 18.0f;
    deviceNameFontSize = 11.0f;
    dataFontSize = 12.5f;

    UIFont *mountPointFont = [UIFont systemFontOfSize:mountPointFontSize];
    UIFont *deviceNameFont = [UIFont systemFontOfSize:deviceNameFontSize];
    UIFont *dataLabelFont = [UIFont systemFontOfSize:dataFontSize];
    UIFont *dataValueFont = [UIFont boldSystemFontOfSize:dataFontSize];
    
    UIColor *mountPointColor = [UIColor blackColor];
    UIColor *deviceNameColor = [UIColor darkTextColor];
    UIColor *dataLabelColor = [UIColor darkGrayColor];
    
    NSString *totalLabelText = [NSString stringWithString:NSLocalizedString(@"DISK_TOTAL_SIZE", nil)];
    NSString *usedLabelText = [NSString stringWithString:NSLocalizedString(@"DISK_USED_SIZE", nil)];
    NSString *availableLabelText = [NSString stringWithString:NSLocalizedString(@"DISK_AVAILABLE_SIZE", nil)];
    NSString *reservedLabelText = [NSString stringWithString:NSLocalizedString(@"DISK_RESERVED_SIZE", nil)];
    
    CGSize totalLabelSize = [totalLabelText sizeWithFont:dataLabelFont];
    CGSize usedLabelSize = [usedLabelText sizeWithFont:dataLabelFont];
    CGSize availableLabelSize = [availableLabelText sizeWithFont:dataLabelFont];
    CGSize reservedLabelSize = [reservedLabelText sizeWithFont:dataLabelFont];
    
    CGFloat labelWidth = totalLabelSize.width;
    if (usedLabelSize.width > labelWidth)
        labelWidth = usedLabelSize.width;
    if (availableLabelSize.width > labelWidth)
        labelWidth = availableLabelSize.width;
    if (reservedLabelSize.width > labelWidth)
            labelWidth = reservedLabelSize.width;
    
    CGRect graphFrame = CGRectMake(CGRectGetMinX(contentFrame) + CGRectGetWidth(contentFrame) + padding.width - graphSize,
                                   CGRectGetMinY(contentFrame) + (CGRectGetHeight(contentFrame) - graphSize) / 2,
                                   graphSize,
                                   graphSize);

    CGRect labelRect;
    CGRect valueRect;
    
    labelRect = contentFrame;
    labelRect.size.height = CGRectGetHeight(contentFrame) * 0.20f;

    self.mountPointLabel = [[UILabel alloc] initWithFrame:labelRect];
    [self.mountPointLabel setBackgroundColor:[UIColor clearColor]];
    [self.mountPointLabel setTextColor:mountPointColor];
    [self.mountPointLabel setFont:mountPointFont];
    
    labelRect.origin.y += labelRect.size.height;
    labelRect.size.height = CGRectGetHeight(contentFrame) * 0.16f;

    self.deviceNameLabel = [[UILabel alloc] initWithFrame:labelRect];
    [self.deviceNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.deviceNameLabel setTextColor:deviceNameColor];
    [self.deviceNameLabel setFont:deviceNameFont];
    
    labelRect = CGRectOffset(labelRect, 0, CGRectGetHeight(labelRect));
    labelRect.size.height = CGRectGetHeight(contentFrame) * 0.16f;
    valueRect = labelRect;

    labelRect.size.width = labelWidth;
    valueRect.origin.x += labelWidth + padding.width;
    valueRect.size.width -= labelWidth;
    
    self.totalLabel = [[UILabel alloc] initWithFrame:labelRect];
    [self.totalLabel setBackgroundColor:[UIColor clearColor]];
    [self.totalLabel setTextColor:dataLabelColor];
    [self.totalLabel setFont:dataLabelFont];
    [self.totalLabel setText:totalLabelText];

    self.totalValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.totalValue setBackgroundColor:[UIColor clearColor]];
    [self.totalValue setTextColor:[UIColor darkTextColor]];
    [self.totalValue setFont:dataValueFont];

    labelRect = CGRectOffset(labelRect, 0, CGRectGetHeight(labelRect));
    valueRect = CGRectOffset(valueRect, 0, CGRectGetHeight(valueRect));
    
    self.usedLabel = [[UILabel alloc] initWithFrame:labelRect];
    [self.usedLabel setBackgroundColor:[UIColor clearColor]];
    [self.usedLabel setTextColor:dataLabelColor];
    [self.usedLabel setFont:dataLabelFont];
    [self.usedLabel setText:usedLabelText];
    
    self.usedValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.usedValue setBackgroundColor:[UIColor clearColor]];
    [self.usedValue setTextColor:[UIColor colorWithRed:1.0f green:0.5f blue:0.0f alpha:1.0f]];
    [self.usedValue setFont:dataValueFont];

    labelRect = CGRectOffset(labelRect, 0, CGRectGetHeight(labelRect));
    valueRect = CGRectOffset(valueRect, 0, CGRectGetHeight(valueRect));
    
    self.availableLabel = [[UILabel alloc] initWithFrame:labelRect];
    [self.availableLabel setBackgroundColor:[UIColor clearColor]];
    [self.availableLabel setTextColor:dataLabelColor];
    [self.availableLabel setFont:dataLabelFont];
    [self.availableLabel setText:availableLabelText];
    
    self.availableValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.availableValue setBackgroundColor:[UIColor clearColor]];
    [self.availableValue setTextColor:[UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f]];
    [self.availableValue setFont:dataValueFont];
    
    labelRect = CGRectOffset(labelRect, 0, CGRectGetHeight(labelRect));
    valueRect = CGRectOffset(valueRect, 0, CGRectGetHeight(valueRect));

    self.reservedLabel = [[UILabel alloc] initWithFrame:labelRect];
    [self.reservedLabel setBackgroundColor:[UIColor clearColor]];
    [self.reservedLabel setTextColor:dataLabelColor];
    [self.reservedLabel setFont:dataLabelFont];
    [self.reservedLabel setText:reservedLabelText];

    self.reservedValue = [[UILabel alloc] initWithFrame:valueRect];
    [self.reservedValue setBackgroundColor:[UIColor clearColor]];
    [self.reservedValue setTextColor:[UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0f]];
    [self.reservedValue setFont:dataValueFont];

    self.diskUsageGraph = [[HALDiskUsageGraph alloc] initWithFrame:graphFrame
                                                             mount:mount];
    
    [self addSubview:self.mountPointLabel];
    [self addSubview:self.deviceNameLabel];
    [self addSubview:self.totalLabel];
    [self addSubview:self.totalValue];
    [self addSubview:self.usedLabel];
    [self addSubview:self.usedValue];
    [self addSubview:self.availableLabel];
    [self addSubview:self.availableValue];
    [self addSubview:self.reservedLabel];
    [self addSubview:self.reservedValue];
    [self addSubview:self.diskUsageGraph];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self setShowBytes:YES];
    } else {
        [self setShowBytes:NO];
    }

    [self refresh];

    return self;
}

- (void)setShowBytes:(Boolean)showBytes
{
    if (showBytes != _showBytes) {
        _showBytes = showBytes;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self refresh];
            
            [UIView beginAnimations:nil
                            context:nil];
            [UIView setAnimationDuration:1.0f];
            
            [self.diskUsageGraph setAlpha:(showBytes) ? 0.0f : 1.0f];
            
            [UIView commitAnimations];
        }
    }
}

- (void)refresh
{
    [self setBackgroundColor:[UIColor colorWithRed:1.000f green:0.800f blue:0.400f alpha:1.0f]];

    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:0.5f];
    
    [self setBackgroundColor:[UIColor whiteColor]];

    CGFloat totalSize = [self.mount totalBlocks];
    CGFloat usedSize = [self.mount totalBlocks] - [self.mount freeBlocks];
    CGFloat availableSize = [self.mount availableBlocks];
    CGFloat reservedSize;
    
    totalSize *= [self.mount blockSize];
    usedSize *= [self.mount blockSize];
    availableSize *= [self.mount blockSize];
    reservedSize = totalSize - usedSize - availableSize;
    
    [self.mountPointLabel setText:[self.mount mountPoint]];
    [self.deviceNameLabel setText:[self.mount deviceName]];
    
    NSString *text;
    
    if ([self showBytes]) {
        text = [NSString stringWithFormat:@"%@  (%0.0f)",
                [self formattedSize:totalSize units:HALFormatSizeUnitsAuto], totalSize];
        [self.totalValue setText:text];
        
        text = [NSString stringWithFormat:@"%@  (%0.0f)",
                [self formattedSize:usedSize units:HALFormatSizeUnitsAuto], usedSize];
        [self.usedValue setText:text];
        
        text = [NSString stringWithFormat:@"%@  (%0.0f)",
                [self formattedSize:availableSize units:HALFormatSizeUnitsAuto], availableSize];
        [self.availableValue setText:text];
        
        text = [NSString stringWithFormat:@"%@  (%0.0f)",
                [self formattedSize:reservedSize units:HALFormatSizeUnitsAuto], reservedSize];
        [self.reservedValue setText:text];
    } else {
        [self.totalValue setText:[self formattedSize:totalSize units:HALFormatSizeUnitsAuto]];
        [self.usedValue setText:[self formattedSize:usedSize units:HALFormatSizeUnitsAuto]];
        [self.availableValue setText:[self formattedSize:availableSize units:HALFormatSizeUnitsAuto]];
        [self.reservedValue setText:[self formattedSize:reservedSize units:HALFormatSizeUnitsAuto]];
    }

    [self.diskUsageGraph updateGraph];

    [UIView commitAnimations];
}

@end
