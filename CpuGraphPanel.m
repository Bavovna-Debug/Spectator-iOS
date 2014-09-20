//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "CpuGraph.h"
#import "CpuGraphPanel.h"

@interface CpuGraphPanel ()

@property (strong, nonatomic) UIView *graphView;
@property (strong, nonatomic) CpuGraph *graph;

@end

@implementation CpuGraphPanel

- (id)initWithHeight:(CGFloat)height
               title:(NSString *)title
{
    self = [super initWithHeight:height
                           title:title];
    if (self == nil)
        return nil;

    CGRect graphFrame = [self contentFrame];

    self.graphView = [[UIView alloc] initWithFrame:graphFrame];
    [self.graphView setBackgroundColor:[UIColor blackColor]];
    [self.graphView.layer setCornerRadius:2.0f];
    [self addSubview:self.graphView];

    graphFrame = CGRectMake(0, 2, CGRectGetWidth(graphFrame) - 2, CGRectGetHeight(graphFrame) - 4);

    NSString *backgroundName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        ? @"CPUGraphBackgroundPad"
        : @"CPUGraphBackgroundPhone";
    UIImageView *backgound = [[UIImageView alloc] initWithFrame:graphFrame];
    [backgound setImage:[UIImage imageNamed:backgroundName]];
    [self.graphView addSubview:backgound];

    self.graph = [[CpuGraph alloc] initWithFrame:graphFrame
                                       graphType:CpuGraphTypeTotal];
    [self.graphView addSubview:self.graph];

    return self;
}

- (void)serverDidSet
{
    [super serverDidSet];

    [self.graph setServer:self.server];
}

- (void)refresh
{
    [super refresh];
    
    [self.graph setNeedsDisplay];
}

@end
