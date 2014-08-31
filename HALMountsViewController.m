//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALMountPanel.h"
#import "HALMountsRecorder.h"
#import "HALMountsViewController.h"
#import "HALPanelTableView.h"
#import "HALPanelTableViewCell.h"

@interface HALMountsViewController ()
    <HALMountsRecorderDelegate>

@property (strong, nonatomic) HALPanelTableView *tableView;

@end

@implementation HALMountsViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;

    self.tableView = [[HALPanelTableView alloc] initWithFrame:frame];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(cellSwipeLeft:)];
        [swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.tableView addGestureRecognizer:swipeLeftGesture];
        
        UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(cellSwipeRight:)];
        [swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.tableView addGestureRecognizer:swipeRightGesture];
    }

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[self.server mountsRecorder] setDelegate:self];

    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self.server mountsRecorder] setDelegate:nil];

    [super viewDidDisappear:animated];
}

- (void)mountsReset
{
    [self.tableView reloadData];
}

- (void)mountDetected:(HALMount *)mount
{
    [self.tableView reloadData];
}

- (void)mountChanged:(HALMount *)mount
{
    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            HALPanelTableViewCell *cell = (HALPanelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            HALMountPanel *panel = (HALMountPanel *)[cell panel];
            if ([panel mount] == mount)
                [panel refresh];
        }
    }
}

- (void)serverDidSet
{
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[self.server mountsRecorder] mounts] count];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HALMount *mount = [[[self.server mountsRecorder] mounts] objectAtIndex:indexPath.row];
    HALPanelTableViewCell *cell = [self cellForMount:mount];

    HALPanel *panel = [cell panel];
    return CGRectGetHeight([panel frame]) + self.tableView.margin.height * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HALMount *mount = [[[self.server mountsRecorder] mounts] objectAtIndex:indexPath.row];
    return [self cellForMount:mount];
}

- (HALPanelTableViewCell *)cellForMount:(HALMount *)mount
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Mount-%@-%@",
                                [self.server dnsName],
                                [mount mountPoint]];
    
    HALPanelTableViewCell *cell;
    cell = (HALPanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        HALMountPanel *panel = [[HALMountPanel alloc] initWithMount:mount];
        cell = [[HALPanelTableViewCell alloc] initWithPanel:panel
                                            reuseIdentifier:cellIdentifier];
    }
    return cell;
}

- (void)cellSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    HALPanelTableViewCell *cell = (HALPanelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    HALMountPanel *panel = (HALMountPanel *)[cell panel];
    [panel setShowBytes:NO];
}

- (void)cellSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    HALPanelTableViewCell *cell = (HALPanelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    HALMountPanel *panel = (HALMountPanel *)[cell panel];
    [panel setShowBytes:YES];
}

@end
