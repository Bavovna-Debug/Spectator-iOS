//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALApplicationDelegate.h"
#import "HALIntroductionViewController.h"

@interface HALIntroductionViewController ()

@property (nonatomic, strong) UIScrollView *introductionScrollView;

@end

@implementation HALIntroductionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self == nil)
        return nil;
    
    [self.view setBackgroundColor:[UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f]];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    assert(self.introductionScrollView == nil);
    
    CGRect frame = [self.view bounds];
    NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];
    if ([deviceVersion floatValue] >= 7.0f) {
        frame.origin.y += 20;
        frame.size.height -= 20;
    }
    
    UINavigationBar *navigationBar = [self addNavigationBar:frame];
    
    frame.origin.y += CGRectGetHeight([navigationBar frame]);
    frame.size.height -= CGRectGetHeight([navigationBar frame]);
    
    frame.origin.y += 1;
    frame.size.height -= 2;
    
    CGSize margin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        ? CGSizeMake(16, 16)
        : CGSizeMake(12, 12);

    UIColor *backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    
    UIFont *introductionFont = [UIFont systemFontOfSize:14.0f];
    
    NSString *introductionText = NSLocalizedStringFromTable(@"INTRODUCTION",
                                                            @"Introduction",
                                                            nil);
    CGSize textSize = [introductionText sizeWithFont:introductionFont
                                   constrainedToSize:CGSizeMake(frame.size.width - 2 * margin.width, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    CGRect textFrame = CGRectMake(margin.width,
                                  margin.height,
                                  frame.size.width - 2 * margin.width,
                                  textSize.height);

    UILabel *introductionTextLabel = [[UILabel alloc] initWithFrame:textFrame];
    [introductionTextLabel setBackgroundColor:[UIColor clearColor]];
    [introductionTextLabel setText:introductionText];
    [introductionTextLabel setFont:introductionFont];
    [introductionTextLabel setTextColor:[UIColor darkTextColor]];
    [introductionTextLabel setTextAlignment:NSTextAlignmentLeft];
    [introductionTextLabel setNumberOfLines:0];
    [introductionTextLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    self.introductionScrollView = [[UIScrollView alloc] initWithFrame:frame];
    [self.introductionScrollView setBackgroundColor:backgroundColor];
    [self.introductionScrollView setContentSize:CGSizeMake(frame.size.width,
                                                           textSize.height + 2 * margin.height)];
    [self.view addSubview:self.introductionScrollView];
    
    [self.introductionScrollView addSubview:introductionTextLabel];
}

- (UINavigationBar *)addNavigationBar:(CGRect)frame
{
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(frame.origin.x,
                                                                                       frame.origin.y,
                                                                                       frame.size.width,
                                                                                       44)];
    [navigationBar setTintColor:[UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f]];
    [self.view addSubview:navigationBar];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"INTRODUCTION_BACK_BUTTON", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didTouchBackButton)];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"INTRODUCTION_PAGE_TITLE", nil)];
    
    [navigationItem setLeftBarButtonItem:backButton
                                animated:NO];
    [navigationBar setItems:[NSArray arrayWithObject:navigationItem]
                   animated:NO];
    
    return navigationBar;
}

- (void)didTouchBackButton
{
    HALApplicationDelegate *application = (HALApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToMainPage];
}

@end