//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALApplicationDelegate.h"
#import "HALDesigner.h"
#import "HALMainViewController.h"
#import "HALServer.h"
#import "HALServerPool.h"
#import "HALServersTable.h"
#import "HALServersTableCell.h"

@interface HALServersTable () <HALServerPoolDelegate>

@end

@implementation HALServersTable

#pragma mark UI initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame
                          style:UITableViewStylePlain];
    if (self == nil)
        return nil;
    
    [self setBackgroundColor:[UIColor serversTableBackground]];
    
    self.delegate = self;
    self.dataSource = self;
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
        self.separatorInset = UIEdgeInsetsZero;
    self.separatorColor = [UIColor serversTableSeparator];

    [[HALServerPool sharedServerPool] setDelegate:self];

    return self;
}

#pragma mark UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    HALServerPool *serverPool = [HALServerPool sharedServerPool];
    return [[serverPool servers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HALServersTableCell *cell;
    
    HALServerPool *serverPool = [HALServerPool sharedServerPool];
    HALServer *server = [[serverPool servers] objectAtIndex:indexPath.row];
    cell = [[HALServersTableCell alloc] initWithServer:server];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HALServerPool *serverPool = [HALServerPool sharedServerPool];
    HALServer *server = [[serverPool servers] objectAtIndex:indexPath.row];
    
    HALApplicationDelegate *application = (HALApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToServer:server];
}

#pragma mark Class specific

- (void)serverSatusChanged:(NSObject *)server
{
    [self reloadData];
}

@end
