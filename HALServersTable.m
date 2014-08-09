//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALApplicationDelegate.h"
#import "HALMainViewController.h"
#import "HALServer.h"
#import "HALServerPool.h"
#import "HALServersTable.h"
#import "HALServersTableCell.h"

@implementation HALServersTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame
                          style:UITableViewStylePlain];
    if (self == nil)
        return nil;
    
    [self setBackgroundColor:[UIColor colorWithRed:1.000f green:0.929f blue:0.831f alpha:1.0f]];
    
    self.delegate = self;
    self.dataSource = self;
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
        self.separatorInset = UIEdgeInsetsZero;
    self.separatorColor = [UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f];

    return self;
}

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

@end
