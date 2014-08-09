//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HALServer.h"

@interface HALMonitorViewController : UIViewController

@property (weak, nonatomic) HALServer *server;

- (id)initWithFrame:(CGRect)frame;

- (HALServer *)server;

- (void)setServer:(HALServer *)server;

- (void)serverDidSet;

@end
