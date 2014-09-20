//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "Designer.h"
#import "MainViewController.h"
#import "ServersTable.h"

@interface MainViewController ()

@property (strong, nonatomic) ServersTable *serversTable;

@end

@implementation MainViewController

#pragma mark UI initialization

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self == nil)
        return nil;

    [self.view setBackgroundColor:[UIColor commonBackground]];

    return self;
}

#pragma mark UI events

- (void)viewDidLoad
{
    [super viewDidLoad];

    assert(self.serversTable == nil);

    CGRect frame = [self.view bounds];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        frame.origin.y += 20;
        frame.size.height -= 20;
    }
    
    UINavigationBar *navigationBar = [self addNavigationBar:frame];
    
    frame.origin.y += CGRectGetHeight([navigationBar frame]);
    frame.size.height -= CGRectGetHeight([navigationBar frame]);
    
    frame.origin.y += 1;
    frame.size.height -= 2;

    self.serversTable = [[ServersTable alloc] initWithFrame:frame];

    [self.view addSubview:self.serversTable];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.serversTable reloadData];
}

#pragma mark UI events help methods

- (UINavigationBar *)addNavigationBar:(CGRect)frame
{
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(frame.origin.x,
                                                                                       frame.origin.y,
                                                                                       frame.size.width,
                                                                                       44)];
    [navigationBar setTintColor:[UIColor navigationBarTint]];
    [self.view addSubview:navigationBar];
    
    UIBarButtonItem *introductionButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"INTRODUCTION_BUTTON", nil)
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(didTouchIntroductionButton)];
    
    UIBarButtonItem *addServerButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADD_SERVER_BUTTON", nil)
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(didTouchAddServerButton)];

    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"SERVER_LIST_TITLE", nil)];
    
    [navigationItem setLeftBarButtonItem:introductionButton
                                animated:NO];
    [navigationItem setRightBarButtonItem:addServerButton
                                 animated:NO];
    [navigationBar setItems:[NSArray arrayWithObject:navigationItem]
                   animated:NO];
    
    return navigationBar;
}

#pragma mark UIButton events

- (void)didTouchIntroductionButton
{
    ApplicationDelegate *application = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToIntroduction];
}

- (void)didTouchAddServerButton
{
    ApplicationDelegate *application = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToEditForm:nil];
}

@end