//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALCpuDetailsPanel.h"
#import "HALCpuGraphPanel.h"
#import "HALCpuViewController.h"
#import "HALMemoryPanel.h"
#import "HALPanelTableView.h"
#import "HALPanelTableViewCell.h"
#import "HALServer.h"
#import "HALServerInformationPanel.h"
#import "HALSwapPanel.h"

@interface HALCpuViewController ()

@property (strong, nonatomic) HALPanelTableView *tableView;
@property (strong, nonatomic) HALServerInformationPanel *informationPanel;
@property (strong, nonatomic) HALCpuGraphPanel *cpuGraphPanel;
@property (strong, nonatomic) HALCpuDetailsPanel *cpuChartsPanel;
@property (strong, nonatomic) HALMemoryPanel *memoryPanel;
@property (strong, nonatomic) HALSwapPanel *swapPanel;

@end

@implementation HALCpuViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;

    self.tableView = [[HALPanelTableView alloc] initWithFrame:frame];
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
        cpuChartsPanelHeight = 144.0f;
        memoryPanelHeight = 96.0f;
        swapPanelHeight = 74.0f;
    }

    self.informationPanel = [[HALServerInformationPanel alloc] initWithHeight:informationPanelHeight];

    self.cpuGraphPanel = [[HALCpuGraphPanel alloc] initWithHeight:cpuGraphPanelHeight
                                                            title:cpuGraphTitle];
    
    self.cpuChartsPanel = [[HALCpuDetailsPanel alloc] initWithHeight:cpuChartsPanelHeight
                                                    title:cpuChartsTitle];
    
    self.memoryPanel = [[HALMemoryPanel alloc] initWithHeight:memoryPanelHeight
                                                        title:memoryPanelTitle];
    
    self.swapPanel = [[HALSwapPanel alloc] initWithHeight:swapPanelHeight
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverParameterChanged:)
                                                 name:@"ServerParameterChanged"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverStatusDidChange:)
                                                 name:@"ConnectedToServer"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverStatusDidChange:)
                                                 name:@"DisconnectedFromServer"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverUptimeReported:)
                                                 name:@"ServerUptimeReported"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clockProcessor:)
                                                 name:@"ClockProcessor"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(memoryInfoChanged:)
                                                 name:@"MemoryInfoChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(swapInfoChanged:)
                                                 name:@"SwapInfoChanged"
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ServerParameterChanged"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ConnectedToServer"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"DisconnectedFromServer"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ServerUptimeReported"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ClockProcessor"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"MemoryInfoChanged"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"SwapInfoChanged"
                                                  object:nil];
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
            HALPanelTableViewCell *cell;
            cell = (HALPanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[HALPanelTableViewCell alloc] initWithPanel:self.informationPanel
                                                    reuseIdentifier:cellIdentifier];
            }
            return cell;
        }

        case 1:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"CpuGraph-%@",
                                        [self.server dnsName]];
            HALPanelTableViewCell *cell;
            cell = (HALPanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[HALPanelTableViewCell alloc] initWithPanel:self.cpuGraphPanel
                                                    reuseIdentifier:cellIdentifier];
            }
            return cell;
        }
            
        case 2:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"CpuCharts-%@",
                                        [self.server dnsName]];
            HALPanelTableViewCell *cell;
            cell = (HALPanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[HALPanelTableViewCell alloc] initWithPanel:self.cpuChartsPanel
                                                    reuseIdentifier:cellIdentifier];
            }
            return cell;
        }

        case 3:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"Memory-%@",
                                        [self.server dnsName]];
            HALPanelTableViewCell *cell;
            cell = (HALPanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[HALPanelTableViewCell alloc] initWithPanel:self.memoryPanel
                                                    reuseIdentifier:cellIdentifier];
            }
            return cell;
        }

        case 4:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"SWAP-%@",
                                        [self.server dnsName]];
            HALPanelTableViewCell *cell;
            cell = (HALPanelTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[HALPanelTableViewCell alloc] initWithPanel:self.swapPanel
                                                    reuseIdentifier:cellIdentifier];
            }
            return cell;
        }

        default:
            return nil;
    }
}

- (void)serverParameterChanged:(NSNotification *)note
{
    HALServer *serverThatDidChange = note.object;
    
    if (serverThatDidChange == self.server)
        [self.informationPanel updateContent];
}

- (void)serverStatusDidChange:(NSNotification *)note
{
    HALServer *serverThatDidChange = note.object;
    
    if (serverThatDidChange == self.server)
        [self.informationPanel updateContent];
}

- (void)serverUptimeReported:(NSNotification *)note
{
    HALServer *serverThatDidReport = note.object;
    
    if (serverThatDidReport == self.server)
        [self.informationPanel updateContent];
}

- (void)clockProcessor:(NSNotification *)note
{
    HALServer *server = note.object;
    if (server == [self server]) {
        [self.cpuGraphPanel refresh];
        [self.cpuChartsPanel refresh];
    }
}

- (void)memoryInfoChanged:(NSNotification *)note
{
    HALServer *server = note.object;
    if (server == [self server]) {
        [self.memoryPanel refresh];
    }
}

- (void)swapInfoChanged:(NSNotification *)note
{
    HALServer *server = note.object;
    if (server == [self server]) {
        [self.swapPanel refresh];
    }
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