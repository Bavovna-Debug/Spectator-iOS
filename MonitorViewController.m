//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "MonitorViewController.h"

@implementation MonitorViewController

@synthesize server = _server;

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.server = nil;
    
    [self.view setFrame:frame];
    [self.view setBackgroundColor:[UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.0f]];

    return self;
}

- (Server *)server
{
    return _server;
}

- (void)setServer:(Server *)server
{
    if (server != _server) {
        _server = server;
        
        [self serverDidSet];
    }
}

- (void)serverDidSet { }

@end
