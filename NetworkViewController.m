//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "NetworkInterfacePanel.h"
#import "NetworkViewController.h"
#import "PanelTableView.h"
#import "PanelTableViewCell.h"

#import "SRVNetworkInterface.h"
#import "SRVNetworkRecorder.h"

@interface NetworkViewController ()
    <SRVNetworkRecorderDelegate>

@property (strong, nonatomic) PanelTableView *tableView;
@property (nonatomic, strong) NSTimer *stopwatchTimer;

@end

@implementation NetworkViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    self.tableView = [[PanelTableView alloc] initWithFrame:frame];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[self.server networkRecorder] setDelegate:self];

    self.stopwatchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                           target:self
                                                         selector:@selector(hearthbeatStopwatch)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self.server networkRecorder] setDelegate:nil];

    [self.stopwatchTimer invalidate];
    self.stopwatchTimer = nil;
    
    [super viewDidDisappear:animated];
}

- (void)networkInterfacesReset
{
    [self.tableView reloadData];
}

- (void)networkInterfaceDetected:(SRVNetworkInterface *)interface
{
    [self.tableView reloadData];
}

- (void)networkTrafficChanged:(SRVNetworkInterface *)interface
{
    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            PanelTableViewCell *cell = (PanelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            NetworkInterfacePanel *panel = (NetworkInterfacePanel *)[cell panel];
            if ([panel interface] == interface)
                [panel refresh];
        }
    }
}

- (void)hearthbeatStopwatch
{
    if ([self.server monitoringRunning] == NO)
        return;

    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            PanelTableViewCell *cell = (PanelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            NetworkInterfacePanel *panel = (NetworkInterfacePanel *)[cell panel];
            [panel refreshStopwatch];
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
    return [[[self.server networkRecorder] interfaces] count];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SRVNetworkInterface *interface = [[[self.server networkRecorder] interfaces] objectAtIndex:indexPath.row];
    PanelTableViewCell *cell = [self cellForInterface:interface];
    
    Panel *panel = [cell panel];
    return CGRectGetHeight([panel frame]) + self.tableView.margin.height * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SRVNetworkInterface *interface = [[[self.server networkRecorder] interfaces] objectAtIndex:indexPath.row];
    return [self cellForInterface:interface];
}

- (PanelTableViewCell *)cellForInterface:(SRVNetworkInterface *)interface
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Networking-%@-%@",
                                [self.server dnsName],
                                [interface interfaceName]];

    PanelTableViewCell *cell;
    cell = (PanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NetworkInterfacePanel *panel = [[NetworkInterfacePanel alloc] initWithInterface:interface];
        cell = [[PanelTableViewCell alloc] initWithPanel:panel
                                            reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

@end
