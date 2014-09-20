//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Server.h"

@interface MonitorViewController : UIViewController

@property (weak, nonatomic) Server *server;

- (id)initWithFrame:(CGRect)frame;

- (Server *)server;

- (void)setServer:(Server *)server;

- (void)serverDidSet;

@end
