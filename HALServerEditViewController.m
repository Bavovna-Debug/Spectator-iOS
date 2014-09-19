//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALApplicationDelegate.h"
#import "HALDesigner.h"
#import "HALServerEditViewController.h"
#import "HALServerPool.h"

@interface HALServerEditViewController ()

@property (strong, nonatomic) HALServer *server;
@property (strong, nonatomic) UIScrollView *formView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) UITextField *serverNameField;
@property (strong, nonatomic) UITextField *dnsNameField;
@property (strong, nonatomic) UITextField *portNumberField;

@end

@implementation HALServerEditViewController

@synthesize server = _server;

#pragma mark UI initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self == nil)
        return nil;

    [self.view setBackgroundColor:[UIColor serverEditBackground]];

    return self;
}

#pragma mark UI events

- (void)viewDidLoad
{
    [super viewDidLoad];

    assert(self.formView == nil);

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

    UIColor *backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    
    self.formView = [[UIScrollView alloc] initWithFrame:frame];
    [self.formView setContentSize:CGSizeMake(CGRectGetWidth(frame), 0)];
    [self.formView setBackgroundColor:backgroundColor];
    [self.view addSubview:self.formView];
    
    self.serverNameField = [self addField:NSLocalizedString(@"SERVER_EDIT_SERVER_NAME_LABEL", nil)];
    [self addDescription:NSLocalizedString(@"SERVER_EDIT_SERVER_NAME_HELP", nil)];
    
    self.dnsNameField = [self addField:NSLocalizedString(@"SERVER_EDIT_DNS_NAME_LABEL", nil)];
    [self addDescription:NSLocalizedString(@"SERVER_EDIT_DNS_NAME_HELP", nil)];
    
    self.portNumberField = [self addField:NSLocalizedString(@"SERVER_EDIT_PORT_NUMBER_LABEL", nil)];
    [self addDescription:NSLocalizedString(@"SERVER_EDIT_PORT_NUMBER_HELP", nil)];
    
    [self.serverNameField setKeyboardType:UIKeyboardTypeAlphabet];
    [self.serverNameField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [self.serverNameField setAutocorrectionType:UITextAutocorrectionTypeNo];

    [self.dnsNameField setKeyboardType:UIKeyboardTypeURL];
    [self.dnsNameField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.dnsNameField setAutocorrectionType:UITextAutocorrectionTypeNo];

    [self.portNumberField setKeyboardType:UIKeyboardTypeNumberPad];

    UIColor *tmpBackground;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        tmpBackground = [UIColor serverEditServerNameBackgroundPad];
    } else {
        tmpBackground = [UIColor serverEditServerNameBackgroundPod];
    }
    [self.serverNameField.inputAccessoryView setBackgroundColor:tmpBackground];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SERVER_EDIT_CANCEL_BUTTON", nil)
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(didTouchCancelButton)];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SERVER_EDIT_SUBMIT_BUTTON", nil)
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(didTouchSubmitButton)];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"SERVER_EDIT_FORM_TITLE", nil)];

    [navigationItem setLeftBarButtonItem:cancelButton
                                animated:NO];
    [navigationItem setRightBarButtonItem:submitButton
                                 animated:NO];
    [navigationBar setItems:[NSArray arrayWithObject:navigationItem]
                   animated:NO];
    
    return navigationBar;
}

- (void)addDescription:(NSString *)descriptionText
{
    CGRect frame = [self.view bounds];
    CGSize margin = CGSizeMake(12, 4);
    
    UIColor *textColor = [UIColor serverEditDescription];
    UIFont *font = [UIFont systemFontOfSize:13.0f];
    
    CGSize contentSize = [self.formView contentSize];
    
    frame.origin.y = contentSize.height;
    
    CGSize textSize = [descriptionText sizeWithFont:font
                                  constrainedToSize:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    frame.size.height = textSize.height + margin.width * 2;
    
    contentSize.height += frame.size.height;
    [self.formView setContentSize:contentSize];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectInset(frame, margin.width, margin.height)];
    [descriptionLabel setBackgroundColor:[UIColor clearColor]];
    [descriptionLabel setFont:font];
    [descriptionLabel setTextColor:textColor];
    [descriptionLabel setNumberOfLines:0];
    [descriptionLabel setText:descriptionText];
    [self.formView addSubview:descriptionLabel];
}

- (UITextField *)addField:(NSString *)labelText
{
    CGRect frame = [self.view bounds];
    CGSize margin = CGSizeMake(12, 4);
    
    UIColor *backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    UIColor *labelTextColor = [UIColor serverEditLabel];
    UIColor *fieldTextColor = [UIColor serverEditField];
    UIFont *labelFont = [UIFont systemFontOfSize:15.0f];
    UIFont *fieldFont = [UIFont systemFontOfSize:15.0f];
    
    CGSize contentSize = [self.formView contentSize];
    
    frame.origin.y = contentSize.height + 24;
    frame.size.height = 32;
    
    contentSize.height = frame.origin.y + frame.size.height;
    [self.formView setContentSize:contentSize];
    
    UIView *fieldLineView = [[UIView alloc] initWithFrame:CGRectInset(frame, -1, 0)];
    [fieldLineView setBackgroundColor:backgroundColor];
    [self.formView addSubview:fieldLineView];
    [fieldLineView.layer setBorderColor:[[UIColor serverEditBorder] CGColor]];
    [fieldLineView.layer setBorderWidth:1.0f];

    CGSize textSize = [labelText sizeWithFont:labelFont];
    textSize.width += 2 * margin.width;
    CGRect labelRect = CGRectMake(0, 0, textSize.width, frame.size.height);
    CGRect fieldRect = CGRectMake(textSize.width, 0, frame.size.width - textSize.width, frame.size.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(labelRect, margin.width, margin.height)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:labelTextColor];
    [label setFont:labelFont];
    [label setText:labelText];
    [fieldLineView addSubview:label];
    
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectInset(fieldRect, 0, margin.height)];
    [field setInputAccessoryView:self.inputView];
    [field setFont:fieldFont];
    [field setTextColor:fieldTextColor];
    [fieldLineView addSubview:field];
    
    return field;
}

#pragma mark UIButton events

- (void)didTouchCancelButton
{
    HALApplicationDelegate *application = (HALApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToMainPage];
}

- (void)didTouchSubmitButton
{
    NSString *serverName = [self.serverNameField text];
    NSString *dnsName = [self.dnsNameField text];
    UInt16 portNumber = [[self.portNumberField text] intValue];
    
    HALServerPool *serverPool = [HALServerPool sharedServerPool];

    if (self.server == nil) {
        HALServer *server = [[HALServer alloc] initWithName:serverName
                                                    dnsName:dnsName];
        [serverPool.servers addObject:server];
    } else {
        [self.server setServerName:serverName];
        [self.server setDnsName:dnsName];
        [self.server setPortNumber:portNumber];
    }

    [serverPool saveServerList];

    HALApplicationDelegate *application = (HALApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [application switchToMainPage];
}

#pragma mark Notifications handlers

- (void)keyboardWillShow
{
    CGSize contentSize = [self.formView contentSize];
    contentSize.height += (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 264 : 216;
    [self.formView setContentSize:contentSize];
}

- (void)keyboardWillHide
{
    CGSize contentSize = [self.formView contentSize];
    contentSize.height -= (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 264 : 216;
    [self.formView setContentSize:contentSize];
}

#pragma mark Class specific

- (void)setServer:(HALServer *)server
{
    _server = server;
    
    if (server == nil) {
        self.portNumberField.text = @"19150";
    } else {
        self.serverNameField.text = [server serverName];
        self.dnsNameField.text = [server dnsName];
        self.portNumberField.text = [NSString stringWithFormat:@"%d", [server portNumber]];
    }
}

@end
