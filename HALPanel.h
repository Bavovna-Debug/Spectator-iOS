//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HALServer.h"

@interface HALPanel : UIView

typedef enum {
    HALFormatSizeUnitsAuto,
    HALFormatSizeUnitsKB,
    HALFormatSizeUnitsMB,
    HALFormatSizeUnitsGB
} HALFormatSizeUnits;

@property (weak, nonatomic) HALServer *server;
@property (strong, nonatomic) UILabel *panelTitle;
@property (assign, nonatomic) CGSize margin;
@property (assign, nonatomic) CGSize padding;

- (id)initWithHeight:(CGFloat)height
               title:(NSString *)title;

- (void)setServer:(HALServer *)server;

- (void)serverDidSet;

- (void)refresh;

- (CGSize)margin;

- (CGSize)padding;

- (CGRect)contentFrame;

- (UILabel *)addPercentDisplayWithFrame:(CGRect)frame
                                  color:(UIColor *)color
                                   text:(NSString *)text;

- (NSString *)formattedSize:(CGFloat)size
                      units:(HALFormatSizeUnits)units;

@end
