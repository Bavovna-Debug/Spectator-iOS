//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "MountPanel.h"
#import "MountsViewController.h"
#import "PanelTableView.h"
#import "PanelTableViewCell.h"

#import "SRVMountsRecorder.h"

@interface MountsViewController () <SRVMountsRecorderDelegate>

@property (strong, nonatomic) PanelTableView *tableView;

@end

@implementation MountsViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;

    self.tableView = [[PanelTableView alloc] initWithFrame:frame];
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

- (void)mountDetected:(SRVMountRecord *)mount
{
    [self.tableView reloadData];
}

- (void)mountChanged:(SRVMountRecord *)mount
{
    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            PanelTableViewCell *cell = (PanelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            MountPanel *panel = (MountPanel *)[cell panel];
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
    SRVMountRecord *mount = [[[self.server mountsRecorder] mounts] objectAtIndex:indexPath.row];
    PanelTableViewCell *cell = [self cellForMount:mount];

    Panel *panel = [cell panel];
    return CGRectGetHeight([panel frame]) + self.tableView.margin.height * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SRVMountRecord *mount = [[[self.server mountsRecorder] mounts] objectAtIndex:indexPath.row];
    return [self cellForMount:mount];
}

- (PanelTableViewCell *)cellForMount:(SRVMountRecord *)mount
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Mount-%@-%@",
                                [self.server dnsName],
                                [mount mountPoint]];
    
    PanelTableViewCell *cell;
    cell = (PanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        MountPanel *panel = [[MountPanel alloc] initWithMount:mount];
        cell = [[PanelTableViewCell alloc] initWithPanel:panel
                                            reuseIdentifier:cellIdentifier];
    }
    return cell;
}

- (void)cellSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    PanelTableViewCell *cell = (PanelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    MountPanel *panel = (MountPanel *)[cell panel];
    [panel setShowBytes:NO];
}

- (void)cellSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    PanelTableViewCell *cell = (PanelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    MountPanel *panel = (MountPanel *)[cell panel];
    [panel setShowBytes:YES];
}

@end
