//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALApplicationDelegate.h"
#import "HALConnectionsViewController.h"
#import "HALCpuViewController.h"
#import "HALMonitorTabBarController.h"
#import "HALMonitorViewController.h"
#import "HALMountsViewController.h"
#import "HALNetworkViewController.h"

@interface HALMonitorTabBarController ()

@property (weak, nonatomic) HALServer *server;
@property (strong, nonatomic) UINavigationItem *navigationItem2;
@property (strong, nonatomic) HALCpuViewController *cpuViewController;
@property (strong, nonatomic) HALMountsViewController *mountsViewController;
@property (strong, nonatomic) HALNetworkViewController *networkViewController;
@property (strong, nonatomic) HALConnectionsViewController *connectionsViewController;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *stopButton;
@property (strong, nonatomic) UIButton *startButton;
@property (strong, nonatomic) UIButton *pauseButton;

@end

@implementation HALMonitorTabBarController

@synthesize server = _server;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = [self.view bounds];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        frame.origin.y += 20;
        frame.size.height -= 20;
        [self.tabBar setTintColor:[UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f]];
    } else {
        frame.size.height -= 20;
    }

    UINavigationBar *navigationBar = [self addNavigationBar:frame];

    frame.origin.y += CGRectGetHeight([navigationBar frame]);
    frame.size.height -= CGRectGetHeight([navigationBar frame]);
    frame.size.height -= CGRectGetHeight([self.tabBar frame]);
    
    frame.origin.y += 1;
    frame.size.height -= 2;

    self.cpuViewController = [[HALCpuViewController alloc] initWithFrame:frame];
    self.mountsViewController = [[HALMountsViewController alloc] initWithFrame:frame];
    self.networkViewController = [[HALNetworkViewController alloc] initWithFrame:frame];
    self.connectionsViewController = [[HALConnectionsViewController alloc] initWithFrame:frame];
    
    UIImage         *tabImage;
    NSString        *tabName;
    UITabBarItem    *tabBarItem;
    NSArray         *viewControllers;
    
    tabImage = [UIImage imageNamed:@"TabBarButton-CPU"];
    tabName = [NSString stringWithString:NSLocalizedString(@"TAB_NAME_CPU", nil)];
    tabBarItem = [[UITabBarItem alloc] initWithTitle:tabName image:tabImage tag:0];
    [self.cpuViewController setTabBarItem:tabBarItem];

    tabImage = [UIImage imageNamed:@"TabBarButton-Mounts"];
    tabName = [NSString stringWithString:NSLocalizedString(@"TAB_NAME_MOUNTS", nil)];
    tabBarItem = [[UITabBarItem alloc] initWithTitle:tabName image:tabImage tag:0];
    [self.mountsViewController setTabBarItem:tabBarItem];
    
    tabImage = [UIImage imageNamed:@"TabBarButton-Network"];
    tabName = [NSString stringWithString:NSLocalizedString(@"TAB_NAME_NETWORK", nil)];
    tabBarItem = [[UITabBarItem alloc] initWithTitle:tabName image:tabImage tag:0];
    [self.networkViewController setTabBarItem:tabBarItem];
    
    tabImage = [UIImage imageNamed:@"TabBarButton-Connections"];
    tabName = [NSString stringWithString:NSLocalizedString(@"TAB_NAME_CONNECTIONS", nil)];
    tabBarItem = [[UITabBarItem alloc] initWithTitle:tabName image:tabImage tag:0];
    [self.connectionsViewController setTabBarItem:tabBarItem];
    
    viewControllers = [[NSArray alloc] initWithObjects:
                       self.cpuViewController,
                       self.mountsViewController,
                       self.networkViewController,
                       self.connectionsViewController,
                       nil];
    [self setViewControllers:viewControllers];
}

- (UINavigationBar *)addNavigationBar:(CGRect)frame
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f)
        frame.origin.y += 20;

    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(frame.origin.x,
                                                                                       frame.origin.y,
                                                                                       frame.size.width,
                                                                                       44)];
    [navigationBar setTintColor:[UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f]];
    [self.view addSubview:navigationBar];

    UIBarButtonItem *leftPanel = [[UIBarButtonItem alloc] initWithCustomView:[self leftButtonsPanel:[navigationBar bounds]]];

    UIBarButtonItem *rightPanel = [[UIBarButtonItem alloc] initWithCustomView:[self rightButtonsPanel:[navigationBar bounds]]];

    UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil
                                                                                       action:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 6.1f) {
        [negativeSeparator setWidth:-2];
    } else {
        [negativeSeparator setWidth:-12];
    }

    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"GKrellM"];

    [navigationItem setLeftBarButtonItems:@[negativeSeparator, leftPanel]];
    [navigationItem setRightBarButtonItems:@[negativeSeparator, rightPanel]];
    [navigationBar setItems:[NSArray arrayWithObject:navigationItem]];

    self.navigationItem2 = navigationItem;

    return navigationBar;
}

- (UIView *)leftButtonsPanel:(CGRect)navigationBarFrame
{
    UIImage *stopMonitoringImage = [UIImage imageNamed:@"NavBarButton-Back"];
    
    CGRect buttonFrame = CGRectMake(0,
                                    0,
                                    navigationBarFrame.size.height,
                                    navigationBarFrame.size.height);
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:buttonFrame];
    [backButton setBackgroundImage:stopMonitoringImage forState:UIControlStateNormal];
    
    [backButton addTarget:self
                   action:@selector(didTouchBackButton)
         forControlEvents:UIControlEventTouchUpInside];
    
    return backButton;
}

- (UIView *)rightButtonsPanel:(CGRect)navigationBarFrame
{
    UIImage *stopMonitoringImage = [UIImage imageNamed:@"NavBarButton-Stop"];
    UIImage *startMonitoringImage = [UIImage imageNamed:@"NavBarButton-Start"];
    UIImage *pauseMonitoringImage = [UIImage imageNamed:@"NavBarButton-Pause"];
    
    CGRect buttonFrame = CGRectMake(0,
                                    0,
                                    navigationBarFrame.size.height * (stopMonitoringImage.size.width / stopMonitoringImage.size.height),
                                    navigationBarFrame.size.height);

    CGRect buttonsViewFrame = CGRectMake(navigationBarFrame.size.width - buttonFrame.size.width * 3,
                                         0,
                                         buttonFrame.size.width * 3,
                                         navigationBarFrame.size.height);
    
    UIView *buttonsView = [[UIView alloc] initWithFrame:buttonsViewFrame];
    [buttonsView setBackgroundColor:[UIColor clearColor]];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.stopButton setFrame:buttonFrame];
    [self.stopButton setBackgroundImage:stopMonitoringImage forState:UIControlStateNormal];
    
    buttonFrame = CGRectOffset(buttonFrame, buttonFrame.size.width, 0);
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startButton setFrame:buttonFrame];
    [self.startButton setBackgroundImage:startMonitoringImage forState:UIControlStateNormal];
    
    buttonFrame = CGRectOffset(buttonFrame, buttonFrame.size.width, 0);

    self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pauseButton setFrame:buttonFrame];
    [self.pauseButton setBackgroundImage:pauseMonitoringImage forState:UIControlStateNormal];
    
    [buttonsView addSubview:self.stopButton];
    [buttonsView addSubview:self.startButton];
    [buttonsView addSubview:self.pauseButton];
    
    [self.stopButton addTarget:self
                        action:@selector(didTouchStopButton)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.startButton addTarget:self
                         action:@selector(didTouchStartButton)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.pauseButton addTarget:self
                         action:@selector(didTouchPauseButton)
               forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverStatusDidChange:)
                                                 name:@"ConnectedToServer"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverStatusDidChange:)
                                                 name:@"DisconnectedFromServer"
                                               object:nil];
    
    [self updateButtonsStates];

    return buttonsView;
}

- (void)setServer:(HALServer *)server
{
    if (server != _server) {
        _server = server;

        [self.navigationItem2 setTitle:[server serverName]];

        for (HALMonitorViewController *controller in [self viewControllers])
            [controller setServer:server];
        
        [self updateButtonsStates];
    }
}

- (void)serverStatusDidChange:(NSNotification *)note
{
    HALServer *serverThatDidChange = note.object;
    
    if (serverThatDidChange == self.server) {
        [self updateButtonsStates];
    }
}

- (void)updateButtonsStates
{
    if ([self.server monitoringRunning]) {
        [self.stopButton setEnabled:YES];
        [self.startButton setEnabled:NO];
        [self.pauseButton setEnabled:YES];
    } else {
        [self.stopButton setEnabled:YES];
        [self.startButton setEnabled:YES];
        [self.pauseButton setEnabled:NO];
    }
}

- (void)didTouchBackButton
{
    HALApplicationDelegate *application = (HALApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToMainPage];
}

- (void)didTouchStopButton
{
    [self.server stopMonitoring];

    HALApplicationDelegate *application = (HALApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToMainPage];
}

- (void)didTouchStartButton
{
    [self.server startMonitoring];
}

- (void)didTouchPauseButton
{
    [self.server pauseMonitoring];
}

@end
