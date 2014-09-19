//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALApplicationDelegate.h"
#import "HALDesigner.h"
#import "HALServer.h"
#import "HALServerPool.h"
#import "HALServersTableCell.h"

@interface HALServersTableCell ()

@property (retain, nonatomic) HALServer *server;
@property (strong, nonatomic) UILabel *serverNameLabel;
@property (strong, nonatomic) UILabel *dnsNameLabel;
@property (strong, nonatomic) UIButton *startButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UIButton *deleteButton;

@end

@implementation HALServersTableCell
{
    Boolean expanded;
}

#pragma mark UI initialization

- (id)initWithServer:(HALServer *)server
{
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:nil];
    if (self == nil)
        return nil;

    [self setBackgroundColor:[UIColor clearColor]];
    
    self.server = server;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [accessoryButton setFrame:CGRectMake(0, 0, 28, 28)];
        [accessoryButton setBackgroundColor:[UIColor clearColor]];
        [accessoryButton setBackgroundImage:[UIImage imageNamed:@"ServerList-AccessoryButton"]
                                   forState:UIControlStateNormal];
        [accessoryButton addTarget:self
                            action:@selector(didTouchAccessoryButton)
                  forControlEvents:UIControlEventTouchUpInside];
        
        [self setAccessoryView:accessoryButton];
        [self setAccessoryType:UITableViewCellAccessoryDetailButton];
    }

    expanded = NO;

    CGSize cellSize;
    CGFloat margin;
    
    CGFloat serverNameFontSize;
    CGFloat dnsNameFontSize;
    
    CGRect buttonFrame;
    CGRect serverNameFrame;
    CGRect dnsNameFrame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cellSize = CGSizeMake(768.0f, 44.0f);
        margin = 16.0f;
        serverNameFontSize = 18.0f;
        dnsNameFontSize = 14.0f;

        buttonFrame = CGRectMake(cellSize.width - cellSize.height,
                                 0,
                                 cellSize.height,
                                 cellSize.height);

        serverNameFrame = CGRectMake(margin,
                                     0,
                                     cellSize.width - 2 * margin - 2 * CGRectGetWidth(buttonFrame),
                                     cellSize.height / 2);
        
        dnsNameFrame = CGRectMake(margin,
                                  cellSize.height / 2,
                                  cellSize.width - 2 * margin - 2 * CGRectGetWidth(buttonFrame),
                                  cellSize.height / 2);
    } else {
        cellSize = CGSizeMake(320.0f, 44.0f);
        margin = 8.0f;
        serverNameFontSize = 16.0f;
        dnsNameFontSize = 12.0f;

        buttonFrame = CGRectMake(0,
                                 0,
                                 cellSize.height,
                                 cellSize.height);

        serverNameFrame = CGRectMake(2 * CGRectGetWidth(buttonFrame) + margin,
                                     0,
                                     cellSize.width - 2 * margin - 2 * CGRectGetWidth(buttonFrame),
                                     cellSize.height / 2);
        
        dnsNameFrame = CGRectMake(2 * CGRectGetWidth(buttonFrame) + margin,
                                  cellSize.height / 2,
                                  cellSize.width - 2 * margin - 2 * CGRectGetWidth(buttonFrame),
                                  cellSize.height / 2);
    }

    CGRect startButtonFrame;
    CGRect pauseButtonFrame;
    CGRect editButtonFrame;
    CGRect deleteButtonFrame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        startButtonFrame = CGRectOffset(buttonFrame, -CGRectGetWidth(buttonFrame) * 3, 0);
        pauseButtonFrame = CGRectOffset(buttonFrame, -CGRectGetWidth(buttonFrame) * 2, 0);
        editButtonFrame = CGRectOffset(buttonFrame, -CGRectGetWidth(buttonFrame) * 1, 0);
        deleteButtonFrame = buttonFrame;
    } else {
        startButtonFrame = buttonFrame,
        pauseButtonFrame = CGRectOffset(buttonFrame, CGRectGetWidth(buttonFrame) * 1, 0);
        editButtonFrame = CGRectOffset(buttonFrame, CGRectGetWidth(buttonFrame) * 2, 0);
        deleteButtonFrame = CGRectOffset(buttonFrame, CGRectGetWidth(buttonFrame) * 3, 0);
    }
    
    UIFont *serverNameFont = [UIFont systemFontOfSize:serverNameFontSize];
    UIFont *dnsNameFont = [UIFont systemFontOfSize:dnsNameFontSize];
    
    self.serverNameLabel = [[UILabel alloc] initWithFrame:serverNameFrame];
    [self.serverNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.serverNameLabel setText:[self.server serverName]];
    [self.serverNameLabel setTextColor:[UIColor serversTableServerName]];
    [self.serverNameLabel setFont:serverNameFont];
    
    self.dnsNameLabel = [[UILabel alloc] initWithFrame:dnsNameFrame];
    [self.dnsNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.dnsNameLabel setText:[NSString stringWithFormat:@"%@ (%d)",
                                [self.server dnsName],
                                [self.server portNumber]]];
    [self.dnsNameLabel setTextColor:[UIColor serversTableDNSName]];
    [self.dnsNameLabel setFont:dnsNameFont];
    
    UIImage *startMonitoringImage = [UIImage imageNamed:@"ActionButton-Start"];
    UIImage *pauseMonitoringImage = [UIImage imageNamed:@"ActionButton-Pause"];
    UIImage *editButtonImage = [UIImage imageNamed:@"ActionButton-Edit"];
    UIImage *deleteButtonImage = [UIImage imageNamed:@"ActionButton-Delete"];
    
    self.startButton = [[UIButton alloc] initWithFrame:startButtonFrame];
    [self.startButton setBackgroundImage:startMonitoringImage forState:UIControlStateNormal];
    
    self.pauseButton = [[UIButton alloc] initWithFrame:pauseButtonFrame];
    [self.pauseButton setBackgroundImage:pauseMonitoringImage forState:UIControlStateNormal];
    
    self.editButton = [[UIButton alloc] initWithFrame:editButtonFrame];
    [self.editButton setBackgroundImage:editButtonImage forState:UIControlStateNormal];
    
    self.deleteButton = [[UIButton alloc] initWithFrame:deleteButtonFrame];
    [self.deleteButton setBackgroundImage:deleteButtonImage forState:UIControlStateNormal];
    
    [self.contentView addSubview:self.serverNameLabel];
    [self.contentView addSubview:self.dnsNameLabel];
    [self.contentView addSubview:self.startButton];
    [self.contentView addSubview:self.pauseButton];
    [self.contentView addSubview:self.editButton];
    [self.contentView addSubview:self.deleteButton];

    [self updateButtonStates];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.editButton setAlpha:0.0f];
        [self.deleteButton setAlpha:0.0f];
    }
    
    [self.startButton addTarget:self
                         action:@selector(didTouchStartButton)
               forControlEvents:UIControlEventTouchUpInside];
   
    [self.pauseButton addTarget:self
                         action:@selector(didTouchPauseButton)
               forControlEvents:UIControlEventTouchUpInside];

    [self.editButton addTarget:self
                        action:@selector(didTouchEditButton)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.deleteButton addTarget:self
                          action:@selector(didTouchDeleteButton)
                forControlEvents:UIControlEventTouchUpInside];

    return self;
}

#pragma mark Delegate methods

- (void)connectedToServer
{
    [self updateButtonStates];
}

- (void)disconnectedFromServer
{
    [self updateButtonStates];
}

- (void)serverParameterChanged { }

#pragma mark UIButton events

- (void)didTouchAccessoryButton
{
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGFloat offset = CGRectGetWidth([self.editButton bounds]) + CGRectGetWidth([self.deleteButton bounds]);
            
            expanded = !expanded;
            if (expanded) {
                [UIView beginAnimations:nil
                                context:nil];
                [UIView setAnimationDuration:0.5f];
                
                [self.serverNameLabel setFrame:CGRectOffset([self.serverNameLabel frame], offset, 0)];
                [self.dnsNameLabel setFrame:CGRectOffset([self.dnsNameLabel frame], offset, 0)];
                
                [self.serverNameLabel setAlpha:0.75f];
                [self.dnsNameLabel setAlpha:0.5f];
                
                [self.editButton setAlpha:1.0f];
                [self.deleteButton setAlpha:1.0f];
                
                [UIView commitAnimations];
            } else {
                [UIView beginAnimations:nil
                                context:nil];
                [UIView setAnimationDuration:0.5f];
                
                [self.serverNameLabel setFrame:CGRectOffset([self.serverNameLabel frame], -offset, 0)];
                [self.dnsNameLabel setFrame:CGRectOffset([self.dnsNameLabel frame], -offset, 0)];
                
                [self.serverNameLabel setAlpha:1.0f];
                [self.dnsNameLabel setAlpha:1.0f];
                
                [self.editButton setAlpha:0.0f];
                [self.deleteButton setAlpha:0.0f];
                
                [UIView commitAnimations];
            }
        }
    }
}

- (void)didTouchStartButton
{
    [self.server startMonitoring];
}

- (void)didTouchPauseButton
{
    [self.server pauseMonitoring];
}

- (void)didTouchEditButton
{
    HALApplicationDelegate *application = (HALApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToEditForm:self.server];
}

- (void)didTouchDeleteButton
{
    NSString *title = NSLocalizedString(@"ALERT_TITLE_CONFIRMATION", nil);
    NSString *message = NSLocalizedString(@"ALERT_DELETE_SERVER_MESSAGE", nil);
    NSString *cancelButton = NSLocalizedString(@"ALERT_BUTTON_NO", nil);
    NSString *submitButton = NSLocalizedString(@"ALERT_BUTTON_YES", nil);
    
    message = [NSString stringWithFormat:message,
               [self.server serverName]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButton
                                              otherButtonTitles:submitButton, nil];
    
    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        HALServerPool *serverPool = [HALServerPool sharedServerPool];
        [[serverPool servers] removeObject:self.server];
    }

    HALApplicationDelegate *application = (HALApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToMainPage];
}

#pragma mark Class specific

- (void)updateButtonStates
{
    if ([self.server monitoringRunning]) {
        [self.startButton setEnabled:NO];
        [self.pauseButton setEnabled:YES];
        [self.editButton setEnabled:NO];
        [self.deleteButton setEnabled:NO];
    } else {
        [self.startButton setEnabled:YES];
        [self.pauseButton setEnabled:NO];
        [self.editButton setEnabled:YES];
        [self.deleteButton setEnabled:YES];
    }
}

@end
