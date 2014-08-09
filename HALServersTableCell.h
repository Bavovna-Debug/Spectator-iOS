//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HALServer.h"

@interface HALServersTableCell : UITableViewCell <UIAlertViewDelegate>

- (id)initWithServer:(HALServer *)server;

@end
