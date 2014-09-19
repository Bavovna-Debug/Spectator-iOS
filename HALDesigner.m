//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALDesigner.h"

@implementation UIColor (HALDesignerColor)

+ (UIColor *)mainWindowBackground
{
    return [UIColor colorWithRed:0.000f green:0.251f blue:0.502f alpha:1.0f];
}

+ (UIColor *)commonBackground
{
    return [UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f];
}

+ (UIColor *)navigationBarTint
{
    return [UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f];
}

+ (UIColor *)serversTableBackground
{
    return [UIColor colorWithRed:1.000f green:0.929f blue:0.831f alpha:1.0f];
}

+ (UIColor *)serversTableSeparator
{
    return [UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f];
}

+ (UIColor *)serversTableServerName
{
    return [UIColor blackColor];
}

+ (UIColor *)serversTableDNSName
{
    return [UIColor darkGrayColor];
}

+ (UIColor *)serverEditBackground
{
    return [UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f];
}

+ (UIColor *)serverEditServerNameBackgroundPad
{
    return [UIColor colorWithRed:207/255.0f green:210/255.0f blue:214/255.0f alpha:1.0f];
}

+ (UIColor *)serverEditServerNameBackgroundPod
{
    return [UIColor colorWithRed:216/255.0f green:219/255.0f blue:223/255.0f alpha:1.0f];
}

+ (UIColor *)serverEditDescription
{
    return [UIColor darkGrayColor];
}

+ (UIColor *)serverEditLabel
{
    return [UIColor darkTextColor];
}

+ (UIColor *)serverEditField
{
    return [UIColor colorWithRed:0.000f green:0.251f blue:0.502f alpha:1.0f];
}

+ (UIColor *)serverEditBorder
{
    return [UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f];
}

+ (UIColor *)introductionText
{
    return [UIColor darkTextColor];
}

@end