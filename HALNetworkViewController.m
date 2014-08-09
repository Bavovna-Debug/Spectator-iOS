//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALNetworkInterfacePanel.h"
#import "HALNetworkInterface.h"
#import "HALNetworkViewController.h"
#import "HALPanelTableView.h"
#import "HALPanelTableViewCell.h"

@interface HALNetworkViewController ()

@property (strong, nonatomic) HALPanelTableView *tableView;
@property (nonatomic, strong) NSTimer *stopwatchTimer;

@end

@implementation HALNetworkViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    self.tableView = [[HALPanelTableView alloc] initWithFrame:frame];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkInterfacesReset:)
                                                 name:@"NetworkInterfacesReset"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkInterfaceDetected:)
                                                 name:@"NetworkInterfaceDetected"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkTrafficChanged:)
                                                 name:@"NetworkTrafficChanged"
                                               object:nil];

    self.stopwatchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                           target:self
                                                         selector:@selector(hearthbeatStopwatch)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"NetworkInterfacesReset"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"NetworkInterfaceDetected"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"NetworkTrafficChanged"
                                                  object:nil];

    [self.stopwatchTimer invalidate];
    self.stopwatchTimer = nil;
    
    [super viewDidDisappear:animated];
}

- (void)networkInterfacesReset:(NSNotification *)note
{
    [self.tableView reloadData];
}

- (void)networkInterfaceDetected:(NSNotification *)note
{
    [self.tableView reloadData];
}

- (void)networkTrafficChanged:(NSNotification *)note
{
    HALNetworkInterface *interface = note.object;
    
    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            HALPanelTableViewCell *cell = (HALPanelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            HALNetworkInterfacePanel *panel = (HALNetworkInterfacePanel *)[cell panel];
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
            HALPanelTableViewCell *cell = (HALPanelTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            HALNetworkInterfacePanel *panel = (HALNetworkInterfacePanel *)[cell panel];
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
    HALNetworkInterface *interface = [[[self.server networkRecorder] interfaces] objectAtIndex:indexPath.row];
    HALPanelTableViewCell *cell = [self cellForInterface:interface];
    
    HALPanel *panel = [cell panel];
    return CGRectGetHeight([panel frame]) + self.tableView.margin.height * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HALNetworkInterface *interface = [[[self.server networkRecorder] interfaces] objectAtIndex:indexPath.row];
    return [self cellForInterface:interface];
}

- (HALPanelTableViewCell *)cellForInterface:(HALNetworkInterface *)interface
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Networking-%@-%@",
                                [self.server dnsName],
                                [interface interfaceName]];

    HALPanelTableViewCell *cell;
    cell = (HALPanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        HALNetworkInterfacePanel *panel = [[HALNetworkInterfacePanel alloc] initWithInterface:interface];
        cell = [[HALPanelTableViewCell alloc] initWithPanel:panel
                                            reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

@end
