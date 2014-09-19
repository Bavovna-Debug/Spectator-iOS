//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALApplicationDelegate.h"
#import "HALDesigner.h"
#import "HALIntroductionViewController.h"
#import "HALMainViewController.h"
#import "HALMonitorTabBarController.h"
#import "HALServerPool.h"
#import "HALServerEditViewController.h"

@implementation HALApplicationDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:NO];
    
    [application setIdleTimerDisabled:YES];
    
    /*
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleIdentifier = [bundle bundleIdentifier];
    self.version = ([[bundleIdentifier substringFromIndex:[bundleIdentifier length] - 4] compare:@"Lite"] == NSOrderedSame) ? HALVersionLite : HALVersionFull;
    */

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor mainWindowBackground];
    
    [self switchToMainPage];

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[HALServerPool sharedServerPool] prepareForBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[HALServerPool sharedServerPool] prepareForBackground];
}

- (void)switchToMainPage
{
    HALMainViewController *controller = [[HALMainViewController alloc] init];
    [self.window setRootViewController:controller];
}

- (void)switchToIntroduction
{
    HALIntroductionViewController *controller = [[HALIntroductionViewController alloc] init];
    [self.window setRootViewController:controller];
}

- (void)switchToEditForm:(HALServer *)server
{
    HALServerEditViewController *controller = [[HALServerEditViewController alloc] init];
    [controller setServer:server];
    [self.window setRootViewController:controller];
}

- (void)switchToServer:(HALServer *)server
{
    HALMonitorTabBarController *controller;

    controller = (HALMonitorTabBarController *)[server associatedViewController];
    if (controller == nil) {
        controller = [[HALMonitorTabBarController alloc] init];
        [server setAssociatedViewController:controller];
    }

    [controller setServer:server];
    [self.window setRootViewController:controller];
}

@end
