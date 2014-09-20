//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Server.h"

/*
typedef enum {
    Version
    VersionLite
} Version;
*/

@interface ApplicationDelegate : UIResponder <UIApplicationDelegate>

//@property (assign, nonatomic) Version version;
@property (strong, nonatomic) UIWindow *window;

- (void)switchToMainPage;

- (void)switchToIntroduction;

- (void)switchToEditForm:(Server *)server;

- (void)switchToServer:(Server *)server;

@end