//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Server.h"

@interface Panel : UIView

typedef enum {
    FormatSizeUnitsAuto,
    FormatSizeUnitsKB,
    FormatSizeUnitsMB,
    FormatSizeUnitsGB
} FormatSizeUnits;

@property (weak,   nonatomic) Server   *server;
@property (strong, nonatomic) UILabel  *panelTitle;
@property (assign, nonatomic) CGSize   margin;
@property (assign, nonatomic) CGSize   padding;

- (id)initWithHeight:(CGFloat)height
               title:(NSString *)title;

- (void)setServer:(Server *)server;

- (void)serverDidSet;

- (void)refresh;

- (CGSize)margin;

- (CGSize)padding;

- (CGRect)contentFrame;

- (UILabel *)addPercentDisplayWithFrame:(CGRect)frame
                                  color:(UIColor *)color
                                   text:(NSString *)text;

- (NSString *)formattedSize:(CGFloat)size
                      units:(FormatSizeUnits)units;

@end
