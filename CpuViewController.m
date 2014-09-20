//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "CpuDetailsPanel.h"
#import "CpuGraphPanel.h"
#import "CpuViewController.h"
#import "MemoryPanel.h"
#import "SRVMemoryRecorder.h"
#import "PanelTableView.h"
#import "PanelTableViewCell.h"
#import "Server.h"
#import "ServerInformationPanel.h"
#import "SwapPanel.h"
#import "SRVSwapRecorder.h"

@interface CpuViewController ()
    <ServerMonitoringDelegate, SRVProcessorsRecorderDelegate, SRVMemoryRecorderDelegate, SRVSwapRecorderDelegate>

@property (strong, nonatomic) PanelTableView          *tableView;
@property (strong, nonatomic) ServerInformationPanel  *informationPanel;
@property (strong, nonatomic) CpuGraphPanel           *cpuGraphPanel;
@property (strong, nonatomic) CpuDetailsPanel         *cpuChartsPanel;
@property (strong, nonatomic) MemoryPanel             *memoryPanel;
@property (strong, nonatomic) SwapPanel               *swapPanel;

@end

@implementation CpuViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;

    self.tableView = [[PanelTableView alloc] initWithFrame:frame];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];

    NSString *cpuGraphTitle = [NSString stringWithString:NSLocalizedString(@"CPU_USAGE_SUMMARY_GRAPH", nil)];
    NSString *cpuChartsTitle = [NSString stringWithString:NSLocalizedString(@"CPU_USAGE_PER_UNIT", nil)];
    NSString *memoryPanelTitle = [NSString stringWithString:NSLocalizedString(@"MEMORY_USAGE_PANEL", nil)];
    NSString *swapPanelTitle = [NSString stringWithString:NSLocalizedString(@"SWAP_USAGE_PANEL", nil)];

    CGFloat informationPanelHeight;
    CGFloat cpuGraphPanelHeight;
    CGFloat cpuChartsPanelHeight;
    CGFloat memoryPanelHeight;
    CGFloat swapPanelHeight;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        informationPanelHeight = 22.0f;
        cpuGraphPanelHeight = 320.0f;
        cpuChartsPanelHeight = 200.0f;
        memoryPanelHeight = 96.0f;
        swapPanelHeight = 96.0f;
    } else {
        informationPanelHeight = 18.0f;
        cpuGraphPanelHeight = 112.0f;
        cpuChartsPanelHeight = 138.0f;
        memoryPanelHeight = 102.0f;
        swapPanelHeight = 80.0f;
    }

    self.informationPanel = [[ServerInformationPanel alloc] initWithHeight:informationPanelHeight];

    self.cpuGraphPanel = [[CpuGraphPanel alloc] initWithHeight:cpuGraphPanelHeight
                                                         title:cpuGraphTitle];
    
    self.cpuChartsPanel = [[CpuDetailsPanel alloc] initWithHeight:cpuChartsPanelHeight
                                                            title:cpuChartsTitle];
    
    self.memoryPanel = [[MemoryPanel alloc] initWithHeight:memoryPanelHeight
                                                     title:memoryPanelTitle];
    
    self.swapPanel = [[SwapPanel alloc] initWithHeight:swapPanelHeight
                                                 title:swapPanelTitle];

    [self.view addSubview:self.informationPanel];
    [self.view addSubview:self.cpuGraphPanel];
    [self.view addSubview:self.cpuChartsPanel];
    [self.view addSubview:self.memoryPanel];
    [self.view addSubview:self.swapPanel];

    [self.informationPanel setServer:[self server]];
    [self.cpuGraphPanel setServer:[self server]];
    [self.cpuChartsPanel setServer:[self server]];
    [self.memoryPanel setServer:[self server]];
    [self.swapPanel setServer:[self server]];

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.server setMonitoringDelegate:self];
    [[self.server processorsRecorder] setDelegate:self];
    [[self.server memoryRecorder] setDelegate:self];
    [[self.server swapRecorder] setDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.server setMonitoringDelegate:nil];
    [[self.server processorsRecorder] setDelegate:nil];
    [[self.server memoryRecorder] setDelegate:nil];
    [[self.server swapRecorder] setDelegate:nil];

    [super viewDidDisappear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            CGRect frame = [self.informationPanel frame];
            CGSize margin = [self.tableView margin];
            return CGRectGetHeight(frame) + margin.height * 2;
        }
            
        case 1:
        {
            CGRect frame = [self.cpuGraphPanel frame];
            CGSize margin = [self.tableView margin];
            return CGRectGetHeight(frame) + margin.height * 2;
        }
            
        case 2:
        {
            CGRect frame = [self.cpuChartsPanel frame];
            CGSize margin = [self.tableView margin];
            return CGRectGetHeight(frame) + margin.height * 2;
        }
            
        case 3:
        {
            CGRect frame = [self.memoryPanel frame];
            CGSize margin = [self.tableView margin];
            return CGRectGetHeight(frame) + margin.height * 2;
        }
            
        case 4:
        {
            CGRect frame = [self.swapPanel frame];
            CGSize margin = [self.tableView margin];
            return CGRectGetHeight(frame) + margin.height * 2;
        }
            
        default:
            return 0.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"Information-%@",
                                        [self.server dnsName]];
            PanelTableViewCell *cell;
            cell = (PanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[PanelTableViewCell alloc] initWithPanel:self.informationPanel
                                                 reuseIdentifier:cellIdentifier];
            }
            return cell;
        }

        case 1:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"CpuGraph-%@",
                                        [self.server dnsName]];
            PanelTableViewCell *cell;
            cell = (PanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[PanelTableViewCell alloc] initWithPanel:self.cpuGraphPanel
                                                 reuseIdentifier:cellIdentifier];
            }
            return cell;
        }
            
        case 2:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"CpuCharts-%@",
                                        [self.server dnsName]];
            PanelTableViewCell *cell;
            cell = (PanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[PanelTableViewCell alloc] initWithPanel:self.cpuChartsPanel
                                                 reuseIdentifier:cellIdentifier];
            }
            return cell;
        }

        case 3:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"Memory-%@",
                                        [self.server dnsName]];
            PanelTableViewCell *cell;
            cell = (PanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[PanelTableViewCell alloc] initWithPanel:self.memoryPanel
                                                 reuseIdentifier:cellIdentifier];
            }
            return cell;
        }

        case 4:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"SWAP-%@",
                                        [self.server dnsName]];
            PanelTableViewCell *cell;
            cell = (PanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[PanelTableViewCell alloc] initWithPanel:self.swapPanel
                                                 reuseIdentifier:cellIdentifier];
            }
            return cell;
        }

        default:
            return nil;
    }
}

- (void)serverParameterChanged
{
    [self.informationPanel updateContent];
}

- (void)connectedToServer
{
    [self.informationPanel updateContent];
}

- (void)disconnectedFromServer
{
    [self.informationPanel updateContent];
}

- (void)serverUptimeReported
{
    [self.informationPanel updateContent];
}

- (void)clockProcessor
{
    [self.cpuGraphPanel refresh];
    [self.cpuChartsPanel refresh];
}

- (void)memoryInfoChanged
{
    [self.memoryPanel refresh];
}

- (void)swapInfoChanged
{
    [self.swapPanel refresh];
}

- (void)serverDidSet
{
    [super serverDidSet];

    [self.informationPanel setServer:[self server]];
    [self.cpuGraphPanel setServer:[self server]];
    [self.cpuChartsPanel setServer:[self server]];
    [self.memoryPanel setServer:[self server]];
    [self.swapPanel setServer:[self server]];
    
    [self.tableView reloadData];
}

@end