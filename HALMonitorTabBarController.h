//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HALServer.h"

@interface HALMonitorTabBarController : UITabBarController <UINavigationControllerDelegate, UINavigationBarDelegate>

- (void)setServer:(HALServer *)server;

@end
