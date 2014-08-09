//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALPanel.h"

@implementation HALPanel

@synthesize server = _server;
@synthesize margin = _margin;

- (id)initWithHeight:(CGFloat)height
               title:(NSString *)title
{
    CGRect frame = [self panelFrameForHeight:height];
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    [self setHidden:YES];

    CGFloat titleHeight;
    CGFloat fontSize;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        titleHeight = 22.0f;
        fontSize = 14.0f;
    } else {
        titleHeight = 18.0f;
        fontSize = 12.5f;
    }
    
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *textColor = [UIColor darkTextColor];
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    [self setBackgroundColor:backgroundColor];
    [self.layer setBorderWidth:0.5f];
    [self.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [self.layer setCornerRadius:4.0f];
    
    if (title != nil) {
        CGSize padding = [self padding];

        CGRect titleViewFrame = CGRectMake(padding.width,
                                           padding.height,
                                           CGRectGetWidth([self bounds]) - padding.width * 2,
                                           titleHeight);
        ;

        UIView *panelTitleView = [[UIView alloc] initWithFrame:titleViewFrame];
        [panelTitleView setBackgroundColor:[UIColor colorWithRed:0.902f green:0.902f blue:0.902f alpha:1.0f]];
        [panelTitleView.layer setBorderWidth:0.5f];
        [panelTitleView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
        [panelTitleView.layer setCornerRadius:2.0f];
        [self addSubview:panelTitleView];

        CGRect titleFrame = CGRectMake(padding.width,
                                       0,
                                       CGRectGetWidth(titleViewFrame),
                                       CGRectGetHeight(titleViewFrame));

        self.panelTitle = [[UILabel alloc] initWithFrame:titleFrame];
        [self.panelTitle setBackgroundColor:[UIColor clearColor]];
        [self.panelTitle setTextColor:textColor];
        [self.panelTitle setFont:font];
        [self.panelTitle setTextAlignment:NSTextAlignmentLeft];
        [self.panelTitle setAdjustsFontSizeToFitWidth:YES];
        [self.panelTitle setText:title];

        [panelTitleView addSubview:self.panelTitle];
    }
    
    return self;
}

- (void)setServer:(HALServer *)server
{
    if (server != _server) {
        _server = server;
        
        [self serverDidSet];
    }
}

- (void)serverDidSet { }

- (void)refresh { }

- (CGRect)panelFrameForHeight:(CGFloat)height
{
    CGSize margin = [self margin];
    CGSize padding = [self padding];

    return CGRectMake(margin.width,
                      margin.height * 2,
                      [[UIScreen mainScreen] bounds].size.width - margin.width * 2,
                      height + padding.height * 2);
}

- (CGSize)margin
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(8.0f, 4.0f);
    } else {
        return CGSizeMake(4.0f, 2.0f);
    }
}

- (CGSize)padding
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(12.0f, 12.0f);
    } else {
        return CGSizeMake(8.0f, 8.0f);
    }
}

- (CGRect)contentFrame
{
    CGRect contentFrame;
    CGSize padding = [self padding];

    if (self.panelTitle == nil) {
        contentFrame = CGRectMake(padding.width,
                                  padding.height,
                                  CGRectGetWidth([self bounds]) - padding.width * 2,
                                  CGRectGetHeight([self bounds]) - padding.height * 2);
    } else {
        CGRect titleFrame = [self.panelTitle frame];
        contentFrame = CGRectMake(padding.width,
                                  CGRectGetHeight(titleFrame) + padding.height * 2,
                                  CGRectGetWidth([self bounds]) - padding.width * 2,
                                  CGRectGetHeight([self bounds]) - CGRectGetHeight(titleFrame) - padding.height * 3);
    }

    return contentFrame;
}

- (UILabel *)addPercentDisplayWithFrame:(CGRect)frame
                                  color:(UIColor *)color
                                   text:(NSString *)text
{
    CGFloat dataLabelFontSize = 12.5f;
    CGFloat dataValueFontSize = 12.5f;
    
    UIFont *dataLabelFont = [UIFont systemFontOfSize:dataLabelFontSize];
    UIFont *dataValueFont = [UIFont systemFontOfSize:dataValueFontSize];
    
    UIView *displayView = [[UIView alloc] initWithFrame:frame];
    [displayView setBackgroundColor:color];
    [displayView.layer setCornerRadius:2.0f];
    [self addSubview:displayView];
    
    CGSize padding = [self padding];
    CGRect textFrame = CGRectMake(padding.width,
                                  0,
                                  CGRectGetWidth(frame) - padding.width * 2,
                                  CGRectGetHeight(frame));
    
    UILabel *dataLabel = [[UILabel alloc] initWithFrame:textFrame];
    [dataLabel setBackgroundColor:[UIColor clearColor]];
    [dataLabel setTextColor:[UIColor whiteColor]];
    [dataLabel setFont:dataLabelFont];
    [dataLabel setTextAlignment:NSTextAlignmentLeft];
    [dataLabel setText:text];
    [displayView addSubview:dataLabel];
    
    UILabel *dataValue = [[UILabel alloc] initWithFrame:textFrame];
    [dataValue setBackgroundColor:[UIColor clearColor]];
    [dataValue setTextColor:[UIColor whiteColor]];
    [dataValue setFont:dataValueFont];
    [dataValue setTextAlignment:NSTextAlignmentRight];
    [displayView addSubview:dataValue];
    
    return dataValue;
}

- (NSString *)formattedSize:(CGFloat)size
                      units:(HALFormatSizeUnits)units
{
    const double KB = 1024;
    const double MB = 1024 * 1024;
    const double GB = 1024 * 1024 * 1024;
    
    double result;
    NSString *unitsText;

    switch (units)
    {
        case HALFormatSizeUnitsAuto:
        {
            if (size < 10 * KB) {
                result = size;
                unitsText = [NSString stringWithString:NSLocalizedString(@"BYTES", nil)];
                return [NSString stringWithFormat:@"%0.0f %@", result, unitsText];
            } else if (size < MB) {
                result = size / KB;
                unitsText = [NSString stringWithString:NSLocalizedString(@"KB", nil)];
                return [NSString stringWithFormat:@"%0.1f %@", result, unitsText];
            } else if (size < GB) {
                result = size / MB;
                unitsText = [NSString stringWithString:NSLocalizedString(@"MB", nil)];
                return [NSString stringWithFormat:@"%0.1f %@", result, unitsText];
            } else {
                size /= GB;
                if (size < 2048) {
                    result = size;
                    unitsText = [NSString stringWithString:NSLocalizedString(@"GB", nil)];
                } else {
                    result = size / 1024;
                    unitsText = [NSString stringWithString:NSLocalizedString(@"TB", nil)];
                }
                return [NSString stringWithFormat:@"%0.2f %@", result, unitsText];
            }
        }
            
        case HALFormatSizeUnitsKB:
        {
            result = size / KB;
            unitsText = [NSString stringWithString:NSLocalizedString(@"KB", nil)];
            return [NSString stringWithFormat:@"%0.0f %@", result, unitsText];
        }
            
        case HALFormatSizeUnitsMB:
        {
            result = size / MB;
            unitsText = [NSString stringWithString:NSLocalizedString(@"MB", nil)];
            return [NSString stringWithFormat:@"%0.0f %@", result, unitsText];
        }
            
        case HALFormatSizeUnitsGB:
        {
            result = size / GB;
            unitsText = [NSString stringWithString:NSLocalizedString(@"GB", nil)];
            return [NSString stringWithFormat:@"%0.0f %@", result, unitsText];
        }
    }
}

@end
