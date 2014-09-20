//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "Designer.h"
#import "MainViewController.h"
#import "Server.h"
#import "ServerPool.h"
#import "ServersTable.h"
#import "ServersTableCell.h"

@interface ServersTable () <ServerPoolDelegate>

@end

@implementation ServersTable

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

    [[ServerPool sharedServerPool] setDelegate:self];

    return self;
}

#pragma mark UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    ServerPool *serverPool = [ServerPool sharedServerPool];
    return [[serverPool servers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServersTableCell *cell;
    
    ServerPool *serverPool = [ServerPool sharedServerPool];
    Server *server = [[serverPool servers] objectAtIndex:indexPath.row];
    cell = [[ServersTableCell alloc] initWithServer:server];
    
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
    ServerPool *serverPool = [ServerPool sharedServerPool];
    Server *server = [[serverPool servers] objectAtIndex:indexPath.row];
    
    ApplicationDelegate *application = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToServer:server];
}

#pragma mark Class specific

- (void)serverSatusChanged:(NSObject *)server
{
    [self reloadData];
}

@end
