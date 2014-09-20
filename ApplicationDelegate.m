//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "Designer.h"
#import "IntroductionViewController.h"
#import "MainViewController.h"
#import "MonitorTabBarController.h"
#import "ServerEditViewController.h"
#import "ServerPool.h"

@implementation ApplicationDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:NO];
    
    [application setIdleTimerDisabled:YES];
    
    /*
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleIdentifier = [bundle bundleIdentifier];
    self.version = ([[bundleIdentifier substringFromIndex:[bundleIdentifier length] - 4] compare:@"Lite"] == NSOrderedSame) ? VersionLite : VersionFull;
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
    [[ServerPool sharedServerPool] prepareForBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[ServerPool sharedServerPool] prepareForBackground];
}

- (void)switchToMainPage
{
    MainViewController *controller = [[MainViewController alloc] init];
    [self.window setRootViewController:controller];
}

- (void)switchToIntroduction
{
    IntroductionViewController *controller = [[IntroductionViewController alloc] init];
    [self.window setRootViewController:controller];
}

- (void)switchToEditForm:(Server *)server
{
    ServerEditViewController *controller = [[ServerEditViewController alloc] init];
    [controller setServer:server];
    [self.window setRootViewController:controller];
}

- (void)switchToServer:(Server *)server
{
    MonitorTabBarController *controller;

    controller = (MonitorTabBarController *)[server associatedViewController];
    if (controller == nil) {
        controller = [[MonitorTabBarController alloc] init];
        [server setAssociatedViewController:controller];
    }

    [controller setServer:server];
    [self.window setRootViewController:controller];
}

@end
