//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALConnectionsTableCell.h"
#import "HALConnectionsViewController.h"
#import "HALConnectionsRecorder.h"
#import "HALConnectionRecord.h"
#import "HALServer.h"
#import "HALServerPool.h"

@interface HALConnectionsViewController ()
    <HALConnectionsRecorderDelegate>

@property (strong, nonatomic) UITableView *connectionsTable;
@property (strong, nonatomic) NSMutableArray *rows;

@end

@implementation HALConnectionsViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;

    self.rows = [NSMutableArray array];

    self.connectionsTable = [[UITableView alloc] initWithFrame:frame
                                                         style:UITableViewStylePlain];
    [self.connectionsTable setBackgroundColor:[UIColor whiteColor]];
    [self.connectionsTable setDelegate:self];
    [self.connectionsTable setDataSource:self];
    [self.connectionsTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
        [self.connectionsTable setSeparatorInset:UIEdgeInsetsZero];
    [self.connectionsTable setSeparatorColor:[UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f]];
    
    [self.view addSubview:self.connectionsTable];

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for (HALConnectionRecord *record in [[self.server connections] activeConnections])
    {
        HALConnectionsTableCell *cell = [[HALConnectionsTableCell alloc] initWithConnection:record];
        [self.rows insertObject:cell atIndex:0];
    }
    
    [self.connectionsTable reloadData];

    [[self.server connections] setDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self.server connections] setDelegate:nil];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [self.rows removeAllObjects];
    
    [super viewDidDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return [self.rows count];

        case 1:
            return 0;

        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            return [self.rows objectAtIndex:[indexPath row]];
            
        case 1:
            return [self.rows objectAtIndex:[indexPath row]];
            
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HALConnectionsTableCell *cell = [self.rows objectAtIndex:[indexPath row]];
    return [cell cellHeight];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    HALConnectionsTableCell *cell = [self.rows objectAtIndex:[indexPath row]];

    [tableView beginUpdates];
    [cell accessoryButtonTapped];
    [tableView endUpdates];
}

- (void)activeConnectionAppeared:(HALConnectionRecord *)connection
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithObjects:
                                  [NSIndexPath indexPathForRow:0 inSection:0],
                                  nil];

    [self.connectionsTable beginUpdates];
    
    HALConnectionsTableCell *cell = [[HALConnectionsTableCell alloc] initWithConnection:connection];
    [self.rows insertObject:cell atIndex:0];

    [self.connectionsTable insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationLeft];

    [self.connectionsTable endUpdates];
    
    [cell animateAppearance];
}

- (void)activeConnectionDisappeared:(HALConnectionRecord *)connection
{
    NSUInteger rowIndex = 0;
    for (HALConnectionsTableCell *cell in [self rows])
    {
        if ([cell connection] == connection) {
            [cell animateDisappearance];
            
            [self performSelector:@selector(scheduledCellRemove:)
                       withObject:cell
                       afterDelay:2.0f];
            break;
        }
        
        rowIndex++;
    }
}

- (void)activeConnectionsCleared
{
    [self.connectionsTable reloadData];
}

- (void)scheduledCellRemove:(HALConnectionsTableCell *)cell
{
    NSUInteger rowIndex = [self.rows indexOfObject:cell];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithObjects:
                                  [NSIndexPath indexPathForRow:rowIndex inSection:0],
                                  nil];

    [self.connectionsTable beginUpdates];

    [self.rows removeObject:cell];
        
    [self.connectionsTable deleteRowsAtIndexPaths:indexPaths
                                 withRowAnimation:UITableViewRowAnimationRight];
    
    [self.connectionsTable endUpdates];
}

@end
